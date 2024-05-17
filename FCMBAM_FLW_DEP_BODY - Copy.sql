create or replace PACKAGE BODY personalproject_FLW_DEP AS
--
 /* Created By       : ADIGUN IFELOLUWA
  ** Date Created     : 20-07-2023
  **
  ** PURPOSE: FLLUTERWAVE CALL
  **/
--
--
    --
    FUNCTION flw_deposit (pi_rowkey in VARCHAR2) RETURN CLOB IS
         --
    --    v_flutterwave_uri VARCHAR2(100)     := 'https://api.flutterwave.com/v3/payments';
       -- v_flutterwave_uri VARCHAR2(100)     := 'http://10.5.204.55:90/flutterwave/v3/payments';
        v_flutterwave_uri VARCHAR2(100)     := 'http://127.0.0.1:90/flutterwave/v3/payments';
        v_rec OB_10_USR%ROWTYPE;
        v_inst personalproject_10_FLW%ROWTYPE;
        v_json CLOB;
        v_response CLOB;
        v_full_nme VARCHAR2(100);
        v_subcr_id VARCHAR2(100);
        v_status VARCHAR2(50);
        v_trnsc_amnt NUMBER;
        CURSOR c_rec IS
            SELECT *
            FROM OB_10_USR
            WHERE ROW_KEY = pi_rowkey;
        PROCEDURE INIT_REC IS
        BEGIN
            v_inst.ROW_KEY              :=  v_rec.ROW_KEY;
            v_inst.FRST_NME             :=  v_rec.FRST_NME;
            v_inst.MID_NME              :=  v_rec.MID_NME;
            v_inst.LST_NME              :=  v_rec.LST_NME;
            v_inst.PRDCT_SUB            :=  v_rec.USR_SBSCR;
            v_inst.TRANSACTION_DATE     :=  SYSDATE;
            v_inst.TRANSACTION_AMNT     :=  v_trnsc_amnt;
        END;
    BEGIN
        OPEN  c_rec;
        FETCH c_rec INTO v_rec;
        CLOSE c_rec;
        v_full_nme := v_rec.FRST_NME || ' ' || v_rec.LST_NME;
        -- v_trnsc_amnt := v_rec.USR_SBSCR_AMT + 350;
        v_trnsc_amnt := v_rec.USR_SBSCR_AMT;
        INIT_REC;
        DELETE FROM personalproject_10_FLW WHERE ROW_KEY = v_inst.ROW_KEY;
        -- 
        IF v_rec.USR_SBSCR = 'Legacy Money Market Fund' THEN
        v_subcr_id := 'RS_2390A7B7681B01BC9FCE4EA7EF310F5A';
        ELSIF v_rec.USR_SBSCR = 'Legacy Equity Fund' THEN
        v_subcr_id := 'RS_2212FB0FF68D8619AA82E41C3B2F760E';
        ELSIF v_rec.USR_SBSCR = 'Legacy Debt Fund' THEN
        v_subcr_id := 'RS_4D50C993C13FDD2A63A06F7565C1AAA1';
        END IF;
        --
        APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).NAME := 'Authorization';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).value := 'Bearer FLWSECK-c3afd238af7b08ac41c392794d2e7d0a-18a277f8fcavt-X';
        -- APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).value := 'Bearer FLWSECK_TEST-10edbda94ce55c0e7dbe5d55c7432d0c-X'; --Test Key
        APEX_WEB_SERVICE.G_REQUEST_HEADERS(2).NAME := 'Content-Type';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS(2).value := 'application/json';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS(3).NAME := 'User-Agent';
        APEX_WEB_SERVICE.G_REQUEST_HEADERS(3).value := 'personalproject';
        
        v_json := '
            {
                "tx_ref": "'||v_rec.ROW_KEY||'",
                "amount": "'||v_trnsc_amnt||'",
                "currency": "NGN",
                "subaccounts": [
                    {
                    "id": "'||v_subcr_id||'"
                    }
                ],
                "redirect_url": "https://apps.fcmbassetmanagement.com/apex/r/personalproject/personalproject-account-opening-form/flutterwave-response?session='||v('SESSION')||'",
                "customer": {
                    "email": "'||v_rec.USR_EML||'",
                    "phonenumber": "'||v_rec.USR_PHNE_NO||'",
                    "name": "'||v_full_nme||'"
                },
                "customizations": {
                    "title": "FCMB Asset Management Limited",
                    "logo": "https://apps.fcmbassetmanagement.com/apex/r/personalproject/104/files/static/v41/app-104-logo.png"
                }
            }
        ';
        v_response := apex_web_service.make_rest_request(
            p_url         => v_flutterwave_uri,
            p_http_method => 'POST',
            p_body        => v_json
        );
        APEX_JSON.parse(v_response);
        v_status := APEX_JSON.get_varchar2(p_path => 'status');
        logger.log('The status is =>' || v_status,'bvnvalues');
        -- IF v_status = 'success' THEN
        --     INSERT INTO personalproject_10_FLW VALUES v_inst;
        -- END IF;
        logger.log('The response is =>' || v_response,'bvnvalues');
        return v_response;
    END;
    --
--
--
END personalproject_FLW_DEP;