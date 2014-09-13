-- phpMyAdmin SQL Dump
-- version 4.2.7.1
-- http://www.phpmyadmin.net
--
-- Host: ::1
-- Generation Time: Sep 13, 2014 at 09:18 PM
-- Server version: 5.5.37-MariaDB
-- PHP Version: 5.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `zwarserver`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE IF NOT EXISTS `accounts` (
`id` int(10) unsigned NOT NULL,
  `name` varchar(24) NOT NULL,
  `ip` varchar(16) NOT NULL,
  `email` varchar(30) NOT NULL,
  `version` varchar(20) NOT NULL,
  `serial` varchar(64) NOT NULL,
  `hash` varchar(128) NOT NULL,
  `salt` varchar(32) NOT NULL,
  `admin` tinyint(1) unsigned NOT NULL,
  `mapper` tinyint(1) unsigned NOT NULL,
  `exp` int(10) unsigned NOT NULL,
  `money` int(10) NOT NULL,
  `kills` mediumint(6) unsigned NOT NULL,
  `deaths` mediumint(6) unsigned NOT NULL,
  `skin` smallint(6) unsigned NOT NULL,
  `time` int(10) unsigned NOT NULL,
  `medkits` mediumint(6) unsigned NOT NULL,
  `cookies` mediumint(6) unsigned NOT NULL,
  `vip` tinyint(1) unsigned NOT NULL,
  `lastnc` int(10) unsigned NOT NULL,
  `lastlogin` int(10) unsigned NOT NULL,
  `regdate` int(10) unsigned NOT NULL,
  `timeskick` int(10) unsigned NOT NULL,
  `timeslogin` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(10) unsigned NOT NULL,
  `admin_id` int(10) unsigned NOT NULL,
  `reason` varchar(64) NOT NULL,
  `lift` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '0 = perm ban',
  `date` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `blacklist`
--

CREATE TABLE IF NOT EXISTS `blacklist` (
`id` int(10) unsigned NOT NULL,
  `ip` varchar(16) NOT NULL,
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '0 = not directly banned by an admin in a ban command',
  `date` int(10) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `loginlog`
--

CREATE TABLE IF NOT EXISTS `loginlog` (
  `id` int(10) unsigned NOT NULL,
  `ip` varchar(16) NOT NULL,
  `loc` tinyint(1) NOT NULL DEFAULT '0',
  `date` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `maps`
--

CREATE TABLE IF NOT EXISTS `maps` (
`id` mediumint(6) unsigned NOT NULL,
  `mapname` varchar(24) NOT NULL,
  `author` int(10) unsigned NOT NULL,
  `spawnx` float(14,4) NOT NULL,
  `spawny` float(14,4) NOT NULL,
  `spawnz` float(14,4) NOT NULL,
  `spawna` float(14,4) NOT NULL,
  `weather` mediumint(6) NOT NULL,
  `time` mediumint(6) NOT NULL,
  `shopx` float(14,4) NOT NULL,
  `shopy` float(14,4) NOT NULL,
  `shopz` float(14,4) NOT NULL,
  `timesplayed` int(10) unsigned NOT NULL,
  `preload` tinyint(1) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `ncrecords`
--

CREATE TABLE IF NOT EXISTS `ncrecords` (
  `id` int(10) unsigned NOT NULL,
  `newname` varchar(24) NOT NULL,
  `date` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
 ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `bans`
--
ALTER TABLE `bans`
 ADD KEY `id` (`id`);

--
-- Indexes for table `blacklist`
--
ALTER TABLE `blacklist`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loginlog`
--
ALTER TABLE `loginlog`
 ADD KEY `id` (`id`);

--
-- Indexes for table `maps`
--
ALTER TABLE `maps`
 ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `mapname` (`mapname`);

--
-- Indexes for table `ncrecords`
--
ALTER TABLE `ncrecords`
 ADD KEY `id` (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `blacklist`
--
ALTER TABLE `blacklist`
MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `maps`
--
ALTER TABLE `maps`
MODIFY `id` mediumint(6) unsigned NOT NULL AUTO_INCREMENT;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `bans`
--
ALTER TABLE `bans`
ADD CONSTRAINT `bans_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `loginlog`
--
ALTER TABLE `loginlog`
ADD CONSTRAINT `loginlog_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ncrecords`
--
ALTER TABLE `ncrecords`
ADD CONSTRAINT `ncrecords_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
