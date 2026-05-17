-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: hospital_analytics
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admissions`
--

DROP TABLE IF EXISTS `admissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admissions` (
  `hadm_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `admittime` datetime DEFAULT NULL,
  `dischtime` datetime DEFAULT NULL,
  `admission_type` varchar(30) DEFAULT NULL,
  `admission_location` varchar(80) DEFAULT NULL,
  `discharge_location` varchar(80) DEFAULT NULL,
  `insurance` varchar(30) DEFAULT NULL,
  `diagnosis` varchar(255) DEFAULT NULL,
  `hospital_expire_flag` int DEFAULT NULL,
  PRIMARY KEY (`hadm_id`),
  KEY `subject_id` (`subject_id`),
  CONSTRAINT `admissions_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `patients` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `d_icd_diagnoses`
--

DROP TABLE IF EXISTS `d_icd_diagnoses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `d_icd_diagnoses` (
  `icd9_code` varchar(10) NOT NULL,
  `short_title` varchar(50) DEFAULT NULL,
  `long_title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`icd9_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `d_icd_procedures`
--

DROP TABLE IF EXISTS `d_icd_procedures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `d_icd_procedures` (
  `icd9_code` varchar(10) NOT NULL,
  `short_title` varchar(50) DEFAULT NULL,
  `long_title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`icd9_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diagnoses_icd`
--

DROP TABLE IF EXISTS `diagnoses_icd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnoses_icd` (
  `subject_id` int DEFAULT NULL,
  `hadm_id` int NOT NULL,
  `seq_num` int NOT NULL,
  `icd9_code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`hadm_id`,`seq_num`),
  KEY `subject_id` (`subject_id`),
  CONSTRAINT `diagnoses_icd_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `patients` (`subject_id`),
  CONSTRAINT `diagnoses_icd_ibfk_2` FOREIGN KEY (`hadm_id`) REFERENCES `admissions` (`hadm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `labevents`
--

DROP TABLE IF EXISTS `labevents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `labevents` (
  `row_id` int NOT NULL,
  `subject_id` int DEFAULT NULL,
  `hadm_id` int DEFAULT NULL,
  `itemid` int DEFAULT NULL,
  `charttime` datetime DEFAULT NULL,
  `value` varchar(200) DEFAULT NULL,
  `valuenum` decimal(10,4) DEFAULT NULL,
  `valueuom` varchar(20) DEFAULT NULL,
  `flag` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`row_id`),
  KEY `subject_id` (`subject_id`),
  CONSTRAINT `labevents_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `patients` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patients` (
  `subject_id` int NOT NULL,
  `gender` char(1) DEFAULT NULL,
  `dob` datetime DEFAULT NULL,
  `dod` datetime DEFAULT NULL,
  `expire_flag` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prescriptions`
--

DROP TABLE IF EXISTS `prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescriptions` (
  `row_id` int NOT NULL,
  `subject_id` int DEFAULT NULL,
  `hadm_id` int DEFAULT NULL,
  `drug` varchar(100) DEFAULT NULL,
  `dose_val_rx` varchar(50) DEFAULT NULL,
  `route` varchar(50) DEFAULT NULL,
  `startdate` datetime DEFAULT NULL,
  `enddate` datetime DEFAULT NULL,
  PRIMARY KEY (`row_id`),
  KEY `subject_id` (`subject_id`),
  KEY `hadm_id` (`hadm_id`),
  CONSTRAINT `prescriptions_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `patients` (`subject_id`),
  CONSTRAINT `prescriptions_ibfk_2` FOREIGN KEY (`hadm_id`) REFERENCES `admissions` (`hadm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procedures_icd`
--

DROP TABLE IF EXISTS `procedures_icd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `procedures_icd` (
  `subject_id` int DEFAULT NULL,
  `hadm_id` int NOT NULL,
  `seq_num` int NOT NULL,
  `icd9_code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`hadm_id`,`seq_num`),
  KEY `subject_id` (`subject_id`),
  CONSTRAINT `procedures_icd_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `patients` (`subject_id`),
  CONSTRAINT `procedures_icd_ibfk_2` FOREIGN KEY (`hadm_id`) REFERENCES `admissions` (`hadm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-07 17:12:40
