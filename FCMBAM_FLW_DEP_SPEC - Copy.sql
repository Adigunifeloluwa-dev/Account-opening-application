create or replace PACKAGE personalproject_FLW_DEP AS
--
 /* Created By       : ADIGUN IFELOLUWA
  ** Date Created     : 20-07-2023
  **
  ** PURPOSE: FLLUTERWAVE CALL
  **/
--
    --
    FUNCTION flw_deposit (pi_rowkey in VARCHAR2) RETURN CLOB;
    --
--
--
END personalproject_FLW_DEP;
