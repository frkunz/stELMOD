$STITLE Unfix Decision Variables

*----------------------------------- UNFIX ALL DAY AHEAD VARIABLES ----------------------------------
* First unfix previously fixed variables
DA_ON.LO(pl,t) = 0; DA_ON.UP(pl,t) = +inf;

DA_CS.LO(pl,t) = 0; DA_CS.UP(pl,t) = +inf;
DA_CD.LO(pl,t) = 0; DA_CD.UP(pl,t) = +inf;

* Storage, generation, wind
DA_L.LO(j,t) = 0; DA_L.UP(j,t) = +inf;
DA_V.LO(j,t) = 0; DA_V.UP(j,t) = +inf;
DA_W.LO(j,t) = 0; DA_W.UP(j,t) = +inf;
DA_GEN.LO(pl,t) = 0; DA_GEN.UP(pl,t) = +inf;
DA_GEN_MAX.LO(pl,t) = 0; DA_GEN_MAX.UP(pl,t) = +inf;
DA_GEN_MIN.LO(pl,t) = 0; DA_GEN_MIN.UP(pl,t) = +inf;
DA_WIND_BID.LO(r,n,t) = 0; DA_WIND_BID.UP(r,n,t) = +inf;
DA_WIND_CURT.LO(r,n,t) = 0; DA_WIND_CURT.UP(r,n,t) = +inf;

* Reserve
DA_RES_S.LO(res,pl,t) = 0; DA_RES_S.UP(res,pl,t) = + inf;
DA_RES_H.LO(res,pl,t) = 0; DA_RES_H.UP(res,pl,t) = + inf;
DA_RES_NS.LO(pl,t) = 0; DA_RES_NS.UP(pl,t) = +inf;

*----------------------------------- UNFIX ALL INTRADAY VARIABLES ----------------------------------
$IFTHEN %case%==1
* First unfix previously fixed variables
ID_ON.LO(pl,t) = 0; ID_ON.UP(pl,t) = +inf;

ID_CS.LO(pl,t) = 0; ID_CS.UP(pl,t) = +inf;
ID_CD.LO(pl,t) = 0; ID_CD.UP(pl,t) = +inf;

* Storage, generation, wind
ID_L.LO(j,t) = 0; ID_L.UP(j,t) = +inf;
ID_V.LO(j,t) = 0; ID_V.UP(j,t) = +inf;
ID_W.LO(j,t) = 0; ID_W.UP(j,t) = +inf;
ID_GEN.LO(pl,t) = 0; ID_GEN.UP(pl,t) = +inf;
ID_GEN_MAX.LO(pl,t) = 0; ID_GEN_MAX.UP(pl,t) = +inf;
ID_GEN_MIN.LO(pl,t) = 0; ID_GEN_MIN.UP(pl,t) = +inf;
ID_WIND_BID.LO(r,n,t) = 0; ID_WIND_BID.UP(r,n,t) = +inf;
ID_WIND_CURT_ID.LO(r,n,t) = -inf; ID_WIND_CURT_ID.UP(r,n,t) = +inf;

$ELSE

* First unfix previously fixed variables
ID_ON.LO(pl,t,k) = 0; ID_ON.UP(pl,t,k) = +inf;

ID_CS.LO(pl,t,k) = 0; ID_CS.UP(pl,t,k) = +inf;
ID_CD.LO(pl,t,k) = 0; ID_CD.UP(pl,t,k) = +inf;

* Storage, generation, wind
ID_L.LO(j,t,k) = 0; ID_L.UP(j,t,k) = +inf;
ID_V.LO(j,t,k) = 0; ID_V.UP(j,t,k) = +inf;
ID_W.LO(j,t,k) = 0; ID_W.UP(j,t,k) = +inf;
ID_GEN.LO(pl,t,k) = 0; ID_GEN.UP(pl,t,k) = +inf;
ID_GEN_MAX.LO(pl,t,k) = 0; ID_GEN_MAX.UP(pl,t,k) = +inf;
ID_GEN_MIN.LO(pl,t,k) = 0; ID_GEN_MIN.UP(pl,t,k) = +inf;
ID_WIND_BID.LO(r,n,t,k) = 0; ID_WIND_BID.UP(r,n,t,k) = +inf;
ID_WIND_CURT_ID.LO(r,n,t,k) = -inf; ID_WIND_CURT_ID.UP(r,n,t,k) = +inf;

$ENDIF
*----------------------------------- UNFIX ALL CONGESTION MANAGEMENT VARIABLES ---------------------
$IFTHEN %case%==1
* generation, wind
CM_ON.LO(pl,t) = 0; CM_ON.UP(pl,t) = +inf;
CM_UP.LO(pl,t) = 0; CM_UP.UP(pl,t) = +inf;
CM_DN.LO(pl,t) = 0; CM_DN.UP(pl,t) = +inf;

CM_CS.LO(pl,t) = 0; CM_CS.UP(pl,t) = +inf;
CM_CD.LO(pl,t) = 0; CM_CD.UP(pl,t) = +inf;

CM_GEN_CM.LO(pl,t) = -inf; CM_GEN_CM.UP(pl,t) = +inf;

CM_L.LO(j,t) = 0; CM_L.UP(j,t) = +inf;
CM_V.LO(j,t) = 0; CM_V.UP(j,t) = +inf;
CM_W.LO(j,t) = 0; CM_W.UP(j,t) = +inf;
CM_GEN.LO(pl,t) = 0; CM_GEN.UP(pl,t) = +inf;
CM_GEN_MAX.LO(pl,t) = 0; CM_GEN_MAX.UP(pl,t) = +inf;
CM_GEN_MIN.LO(pl,t) = 0; CM_GEN_MIN.UP(pl,t) = +inf;
CM_WIND_BID.LO(r,n,t) = 0; CM_WIND_BID.UP(r,n,t) = +inf;
CM_WIND_CURT_CM.LO(r,n,t) = -inf; CM_WIND_CURT_CM.UP(r,n,t) = +inf;
CM_ALPHA.LO(l,t) = -inf; CM_ALPHA.UP(l,t) = +inf;

$ELSE

* generation, wind
CM_ON.LO(pl,t,k) = 0; CM_ON.UP(pl,t,k) = +inf;

CM_CS.LO(pl,t,k) = 0; CM_CS.UP(pl,t,k) = +inf;
CM_CD.LO(pl,t,k) = 0; CM_CD.UP(pl,t,k) = +inf;

CM_GEN_CM.LO(pl,t,k) = -inf; CM_GEN_CM.UP(pl,t,k) = +inf;

CM_L.LO(j,t,k) = 0; CM_L.UP(j,t,k) = +inf;
CM_V.LO(j,t,k) = 0; CM_V.UP(j,t,k) = +inf;
CM_W.LO(j,t,k) = 0; CM_W.UP(j,t,k) = +inf;
CM_GEN.LO(pl,t,k) = 0; CM_GEN.UP(pl,t,k) = +inf;
CM_GEN_MAX.LO(pl,t,k) = 0; CM_GEN_MAX.UP(pl,t,k) = +inf;
CM_GEN_MIN.LO(pl,t,k) = 0; CM_GEN_MIN.UP(pl,t,k) = +inf;
CM_WIND_BID.LO(r,n,t,k) = 0; CM_WIND_BID.UP(r,n,t,k) = +inf;
CM_WIND_CURT_CM.LO(r,n,t,k) = -inf; CM_WIND_CURT_CM.UP(r,n,t,k) = +inf;
CM_ALPHA.LO(l,t,k) = -inf; CM_ALPHA.UP(l,t,k) = +inf;

$ENDIF
