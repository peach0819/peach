v_date=$1

source ../sql_variable.sh $v_date

sh /alidata/workspace/yt_bigdata/edp/finance_order_channel_new/ads_finance_order_ascription_d.sh $v_date &&
sh /alidata/workspace/yt_bigdata/edp/onedata_model/dim_hpc_ord_finance_order_ascription_d.sh $v_date &&

exit 0