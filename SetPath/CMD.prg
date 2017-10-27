set filt to type = 'CR'
APPEND FROM e:\itrader\mbi\data\acct_gen.dbf FOR Acct_gen.type = 'CR'  AND Acct_gen.period_no >12
repl rest Period with left(Period,7)+str(val(subs(period,8,1))+1,1) , number with 0, period_no WITH PERIOD_NO -12