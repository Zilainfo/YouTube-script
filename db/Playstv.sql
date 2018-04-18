CREATE DATABASE YouTube_script;

USE YouTube_script;

CREATE TABLE IF NOT EXISTS `video` (
  `id` INTEGER(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `created` DATETIME NOT NULL,
  `vid` VARCHAR(150) NOT NULL DEFAULT '',
  `type` VARCHAR(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `vid` (`vid`)
)
  COMMENT = 'Video table';

CREATE TABLE IF NOT EXISTS `youtube_video` (
  `id` INTEGER(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `created` DATETIME NOT NULL,
  `vid` VARCHAR(150) NOT NULL DEFAULT '',
  `num` INTEGER(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vid` (`vid`)
)
  COMMENT = 'YVideo table';