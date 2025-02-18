--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

CREATE OR REPLACE VIEW DB_TABLE_SIZE AS   -- Offline version that does not use co-related calls to ADMIN_GET_TAB_INFO table function
SELECT
    T.TABSCHEMA
,   T.TABNAME
,   MAX(DATA_L_KB + INDEX_L_KB + SYN_L_KB, DATA_P_KB + INDEX_P_KB + SYN_P_KB) AS SIZE_KB
,   CASE WHEN DATA_L_KB + INDEX_L_KB + SYN_L_KB > DATA_P_KB + INDEX_P_KB + SYN_P_KB THEN 'LOGICAL'
         WHEN DATA_L_KB + INDEX_L_KB + SYN_L_KB < DATA_P_KB + INDEX_P_KB + SYN_P_KB THEN 'PHYSICAL'
         ELSE 'LOG = PHYS' END AS SIZE_SOURCE
,   DATA_L_KB
,   DATA_P_KB
,   INDEX_L_KB
,   INDEX_P_KB
,   SYN_L_KB
,   SYN_P_KB
,   RECLAIMABLE_KB
FROM
(
    SELECT
        TABSCHEMA
    ,   TABNAME    
    ,   SUM(DATA_OBJECT_L_SIZE +                       LONG_OBJECT_L_SIZE + LOB_OBJECT_L_SIZE + XML_OBJECT_L_SIZE + COL_OBJECT_L_SIZE) AS DATA_L_KB
    ,   SUM(                      INDEX_OBJECT_L_SIZE                                                                                ) AS INDEX_L_KB
    ,   SUM(DATA_OBJECT_P_SIZE +                       LONG_OBJECT_P_SIZE + LOB_OBJECT_P_SIZE + XML_OBJECT_P_SIZE + COL_OBJECT_P_SIZE) AS DATA_P_KB
    ,   SUM(                      INDEX_OBJECT_P_SIZE                                                                                ) AS INDEX_P_KB
    ,   SUM(RECLAIMABLE_SPACE)  AS RECLAIMABLE_KB
    FROM
        ADMIN_GET_TAB_INFO
    WHERE NOT (TABSCHEMA = 'SYSIBM' AND TABNAME LIKE 'SYN%')
    GROUP BY
        TABSCHEMA
    ,   TABNAME
) T
JOIN TABDEP D 
ON  T.TABSCHEMA = D.BSCHEMA AND T.TABNAME = D.BNAME AND D.DTYPE = '7'
JOIN TABLES C      ON  (C.TABSCHEMA = T.TABSCHEMA AND C.TABNAME =  T.TABNAME )
JOIN TABLESPACES A ON  (C.TBSPACE = A.TBSPACE)
INNER JOIN
(
    SELECT
        TABSCHEMA
    ,   TABNAME
    ,   SUM(DATA_OBJECT_L_SIZE +  INDEX_OBJECT_L_SIZE + LONG_OBJECT_L_SIZE + LOB_OBJECT_L_SIZE + XML_OBJECT_L_SIZE + COL_OBJECT_L_SIZE) AS SYN_L_KB
    ,   SUM(DATA_OBJECT_P_SIZE +  INDEX_OBJECT_P_SIZE + LONG_OBJECT_P_SIZE + LOB_OBJECT_P_SIZE + XML_OBJECT_P_SIZE + COL_OBJECT_P_SIZE) AS SYN_P_KB
    FROM
        ADMIN_GET_TAB_INFO
    WHERE TABSCHEMA = 'SYSIBM' AND TABNAME LIKE 'SYN%'
    GROUP BY
        TABSCHEMA
    ,   TABNAME
) S
ON
    S.TABSCHEMA = D.TABSCHEMA AND S.TABNAME =  D.TABNAME 
