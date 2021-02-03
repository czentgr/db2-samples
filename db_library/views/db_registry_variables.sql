--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Shows current database registry variables set on the database server (Db2set)
 */

CREATE OR REPLACE VIEW DB_REGISTRY_VARIABLES AS
SELECT
    REG_VAR_NAME
,   REG_VAR_VALUE
,   CASE WHEN REG_VAR_VALUE <> REG_VAR_ON_DISK_VALUE THEN REG_VAR_ON_DISK_VALUE ELSE '' END AS ON_DISK_VALUE
,   REG_VAR_DEFAULT_VALUE       AS DEFAULT_VALUE
,   LISTAGG(MEMBER,',') WITHIN GROUP (ORDER BY MEMBER) AS MEMBERS
FROM
     TABLE(ENV_GET_REG_VARIABLES(-2, 0))
GROUP BY
    REG_VAR_NAME
,   REG_VAR_VALUE
,   REG_VAR_DEFAULT_VALUE
,   REG_VAR_ON_DISK_VALUE