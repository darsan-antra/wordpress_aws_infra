resource "aws_instance" "bastion" {
  ami           = "ami-04e5276ebb8451442"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.wordpress.key_name
  #  iam_instance_profile = aws_iam_instance_profile.session-manager.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.bastion-host-sg.id]
  subnet_id                   = aws_subnet.public_subnet_1a.id
  provisioner "local-exec" {
    command = "echo '${tls_private_key.bastion.private_key_pem}' > ./wordpress_kp.pem"
  }
  user_data = <<-EOF
      sudo yum update -y
  EOF
  tags = {
    Name = "Bastion"
  }
}

resource "aws_launch_configuration" "wordpress_lb_launch_config" {
  name_prefix     = "wordpress_instance"
  image_id        = var.launch_config_ec2_ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.private_instance_SG.id]
  key_name        = aws_key_pair.wordpress.key_name
  #  iam_instance_profile = aws_iam_instance_profile.session-manager.id
  associate_public_ip_address = false
  provisioner "local-exec" {
    command = "echo '${tls_private_key.bastion.private_key_pem}' > ./wordpress_kp.pem"
  }
  user_data  = <<-EOL
  #!/bin/bash -xe
  sudo yum -y update
  sudo amazon-linux-extras install php8.2
  sudo yum install -y httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  sudo usermod -a -G apache ec2-user
  sudo chown -R ec2-user:apache /var/www
  sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
  find /var/www -type f -exec sudo chmod 0664 {} \;
  sudo wget https://wordpress.org/latest.tar.gz
  sudo tar -xzf latest.tar.gz
  sudo mv wordpress/* /var/www/html/
  sudo chown root:root /var/www/html/
  sudo find /var/www/html/ -type d -exec chmod 755 {} \;
  sudo find /var/www/html/ -type f -exec chmod 644 {} \;
  echo "
  <?php
  /**
   * The base configuration for WordPress
   *
   * The wp-config.php creation script uses this file during the installation.
   * You don't have to use the website, you can copy this file to "wp-config.php"
   * and fill in the values.
   *
   * This file contains the following configurations:
   *
   * * Database settings
   * * Secret keys
   * * Database table prefix
   * * ABSPATH
   *
   * @link https://wordpress.org/documentation/article/editing-wp-config-php/
   *
   * @package WordPress
   */

  // ** Database settings - You can get this info from your web host ** //
  /** The name of the database for WordPress */
  define( 'DB_NAME',  '${var.database_name}');

  /** Database username */
  define( 'DB_USER', 'admin' );

  /** Database password */
  define( 'DB_PASSWORD', '${aws_secretsmanager_secret_version.password.secret_string}' );

  /** Database hostname */
  define( 'DB_HOST', '${aws_instance.wordpress_db.private_dns}' );

  /** Database charset to use in creating database tables. */
  define( 'DB_CHARSET', 'utf8' );

  /** The database collate type. Don't change this if in doubt. */
  define( 'DB_COLLATE', '' );

  /**#@+
   * Authentication unique keys and salts.
   *
   * Change these to different unique phrases! You can generate these using
   * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
   *
   * You can change these at any point in time to invalidate all existing cookies.
   * This will force all users to have to log in again.
   *
   * @since 2.6.0
   */
  define( 'AUTH_KEY',         '${aws_secretsmanager_secret_version.auth_key.secret_string}' );
  define( 'SECURE_AUTH_KEY',  '${aws_secretsmanager_secret_version.secure_auth_key.secret_string}' );
  define( 'LOGGED_IN_KEY',    '${aws_secretsmanager_secret_version.logged_in_key.secret_string}' );
  define( 'NONCE_KEY',        '${aws_secretsmanager_secret_version.nonce_key.secret_string}' );
  define( 'AUTH_SALT',        '${aws_secretsmanager_secret_version.auth_salt.secret_string}' );
  define( 'SECURE_AUTH_SALT', '${aws_secretsmanager_secret_version.secure_auth_salt.secret_string}' );
  define( 'LOGGED_IN_SALT',   '${aws_secretsmanager_secret_version.logged_in_salt.secret_string}' );
  define( 'NONCE_SALT',       '${aws_secretsmanager_secret_version.nonce_salt.secret_string}' );

  /**#@-*/

  /**
   * WordPress database table prefix.
   *
   * You can have multiple installations in one database if you give each
   * a unique prefix. Only numbers, letters, and underscores please!
   */
  $table_prefix = 'wp_';

  /**
   * For developers: WordPress debugging mode.
   *
   * Change this to true to enable the display of notices during development.
   * It is strongly recommended that plugin and theme developers use WP_DEBUG
   * in their development environments.
   *
   * For information on other constants that can be used for debugging,
   * visit the documentation.
   *
   * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
   */
  define( 'WP_DEBUG', false );
  /* Add any custom values between this line and the "stop editing" line. */



  /* That's all, stop editing! Happy publishing. */

  /** Absolute path to the WordPress directory. */
  if ( ! defined( 'ABSPATH' ) ) {
          define( 'ABSPATH', __DIR__ . '/var/www/html/' );
  }

  /** Sets up WordPress vars and included files. */
  require_once ABSPATH . 'wp-settings.php';
  ?>" > /var/www/html/wp-config.php

  sudo service httpd restart
  EOL
  depends_on = [aws_nat_gateway.nat_gateway1, aws_nat_gateway.nat_gateway2, aws_instance.wordpress_db]
}

resource "aws_autoscaling_group" "ec2_cluster" {
  name                 = "wordpress-instance"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.wordpress_lb_launch_config.name
  vpc_zone_identifier  = [aws_subnet.private_subnet_1a_1.id, aws_subnet.private_subnet_1b_1.id]
  target_group_arns    = [aws_alb_target_group.wordpress-tg.arn]
  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "private_instance"
  }
}

resource "aws_key_pair" "wordpress" {
  public_key = tls_private_key.bastion.public_key_openssh
  key_name   = "wordpress_kp"
  provisioner "local-exec" {
    command = "echo '${tls_private_key.bastion.private_key_pem}' > ./wordpress_kp.pem"
  }
}

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
