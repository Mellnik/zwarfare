-- phpMyAdmin SQL Dump
-- version 3.5.8.2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 04, 2014 at 01:01 PM
-- Server version: 5.1.73
-- PHP Version: 5.3.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `zmpserver`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE IF NOT EXISTS `accounts` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(24) NOT NULL,
  `ip` varchar(16) NOT NULL,
  `serial` varchar(64) NOT NULL,
  `hash` varchar(128) NOT NULL,
  `salt` varchar(32) NOT NULL,
  `score` int(10) unsigned NOT NULL,
  `adminlevel` tinyint(1) unsigned NOT NULL,
  `money` int(10) NOT NULL,
  `kills` mediumint(6) unsigned NOT NULL,
  `deaths` mediumint(6) unsigned NOT NULL,
  `time` int(10) unsigned NOT NULL,
  `vip` tinyint(1) NOT NULL,
  `medkits` mediumint(6) unsigned NOT NULL,
  `cookies` mediumint(6) unsigned NOT NULL,
  `lastnc` int(10) unsigned NOT NULL,
  `lastlogin` int(10) unsigned NOT NULL,
  `reg_date` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(24) NOT NULL,
  `adminname` varchar(24) NOT NULL,
  `reason` varchar(128) NOT NULL,
  `lift` int(10) unsigned NOT NULL,
  `date` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `blacklist`
--

CREATE TABLE IF NOT EXISTS `blacklist` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(16) NOT NULL,
  `date` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `maps`
--

CREATE TABLE IF NOT EXISTS `maps` (
  `id` mediumint(6) unsigned NOT NULL AUTO_INCREMENT,
  `mapname` varchar(24) NOT NULL,
  `SpawnX` float(14,4) NOT NULL,
  `SpawnY` float(14,4) NOT NULL,
  `SpawnZ` float(14,4) NOT NULL,
  `SpawnA` float(14,4) NOT NULL,
  `Weather` mediumint(6) NOT NULL,
  `Time` mediumint(6) NOT NULL,
  `ShopX` float(14,4) NOT NULL,
  `ShopY` float(14,4) NOT NULL,
  `ShopZ` float(14,4) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mapname` (`mapname`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `ncrecords`
--

CREATE TABLE IF NOT EXISTS `ncrecords` (
  `id` int(10) unsigned NOT NULL,
  `newname` varchar(24) NOT NULL,
  `date` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
