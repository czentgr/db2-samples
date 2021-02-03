--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Shows current transaction log usage
 */

CREATE OR REPLACE VIEW DB_LOG_USED AS
SELECT * FROM (
SELECT
    MEMBER
,   DECIMAL(TOTAL_LOG_USED / ((TOTAL_LOG_AVAILABLE + TOTAL_LOG_USED) * 1.0)*100,5,2)  AS PCT_LOG_USED
,   ROW_NUMBER() OVER(ORDER BY TOTAL_LOG_USED DESC, MEMBER)     AS RANK
,   (TOTAL_LOG_AVAILABLE + TOTAL_LOG_USED)      /(1024*1024)    AS LOG_SPACE_MB
,   TOTAL_LOG_USED /(1024*1024)                                 AS LOG_USED_MB 
,   APPLID_HOLDING_OLDEST_XACT
,   FIRST_ACTIVE_LOG
,   LAST_ACTIVE_LOG
,   'CALL ADMIN_CMD(''FORCE APPLICATION ( ' || APPLID_HOLDING_OLDEST_XACT || ' )'')'      AS FORCE_STATMET
FROM TABLE(MON_GET_TRANSACTION_LOG(-2))
)
--WHERE RANK < 4