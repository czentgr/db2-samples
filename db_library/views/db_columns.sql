--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Lists all table and view columns in the database
 */

CREATE OR REPLACE VIEW DB_COLUMNS AS
SELECT  
    C.TABSCHEMA
,   C.TABNAME
,   T.TYPE
,   C.COLNAME
,   C.COLNO
,   C.COLCARD
,   C.LENGTH
,   C.STRINGUNITSLENGTH
,   CASE WHEN TYPENAME IN ('BLOB','CLOB','DCLOB') THEN INLINE_LENGTH ELSE LENGTH END
    * CASE C.TYPESTRINGUNITS WHEN 'CODEUNITS32' THEN 4 WHEN 'CODEUNITS16' THEN 2 ELSE 1 END
        AS MAX_ON_PAGE_LENGTH_BYTES
,   SCALE 
,   INLINE_LENGTH
,   NULLS
,   DEFAULT
,   HIDDEN 
FROM
    SYSCAT.COLUMNS C
INNER JOIN
    SYSCAT.TABLES T
USING
   ( TABSCHEMA, TABNAME )