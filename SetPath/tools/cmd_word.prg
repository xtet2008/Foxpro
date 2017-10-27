retu

APPEND FROM d:\heroka\wwx\data\acct_ca.dbf FIELDS B.ac_code,B.acct_id,B.level,B.type,B.profit,B.profit2,B.profit3,B.profit4,B.group1,B.group2,B.group3,B.lookupid,B.ac_desc,B.ac_type,B.year,B.company,B.org_type,B.org_id,B.ac_paren,B.ccy_control,B.ccy,B.bank_ac,B.debit,B.credit,B.balance,B.forward_bal,B.backward_bal,B.prior_bal,B.last_bal,B.lastbudget,B.yearbudget,B.bal_open,B.status,B.lastupdate,B.suppress_rev,B.check_acct,B.org_code,B.credit_limit,B.pay_method,B.terms,B.tax_code,B.direct_dbt,B.disc_day1,B.disc_day2,B.discount1,B.discount2,B.transact,B.a1,B.a2,B.a3,B.a4,B.a5,B.a6,B.period1,B.period2,B.period3,B.period4,B.period5,B.period6,B.period7,B.period8,B.period9,B.period10,B.period11,B.period12,B.period13,B.period14,B.period15,B.period16,B.period17,B.period18,B.period19,B.period20,B.period21,B.period22,B.period23,B.period24,B.budget1,B.budget2,B.budget3,B.budget4,B.budget5,B.budget6,B.budget7,B.budget8,B.budget9,B.budget10,B.budget11,B.budget12,B.budget13,B.budget14,B.budget15,;
B.budget16,B.budget17,B.budget18,B.budget19,B.budget20,B.budget21,B.budget22,B.budget23,B.budget24,B.prior1,B.prior2,B.prior3,B.prior4,B.prior5,B.prior6,B.prior7,B.prior8,B.prior9,B.prior10,B.prior11,B.prior12,B.prior13,B.prior14,B.prior15,B.prior16,B.prior17,B.prior18,B.prior19,B.prior20,B.prior21,B.prior22,B.prior23,B.prior24,B.createdate,B.remarks,B.click,B.last_ccy1,B.last_ccy2,B.last_ccy3,B.last_ccy4,B.last_ccy5,B.last_ccy6,B.last_ccy7,B.last_ccy8,B.last_ccy9,B.last_ccy10,B.this_ccy1,B.this_ccy2,B.this_ccy3,B.this_ccy4,B.this_ccy5,B.this_ccy6,B.this_ccy7,B.this_ccy8,B.this_ccy9,B.this_ccy10,B.clicktime,B.adate,B.cdate,B.ddate,B.adatetime,B.ac_desc2,B.arap_type,B.duedays,B.costing_ac
BROWSE 
blank all field debit ,credit,balance,forward_bal,backward_bal,prior_bal,last_bal
blank all field lastbudget,yearbudget
blank all field period1,period2,period3,period4,period5,period6,period7,period8,period9,period10,period11,period12
blank all field period23,period24,period13,period14,period15,period16,period17,period18,period19,period21,period21,period22
blank all field period23,period24,period13,period14,period15,period16,period17,period18,period19,period20,period21,period22

blank all field this_ccy1,this_ccy2,this_ccy3,this_ccy4,this_ccy5,this_ccy6,this_ccy7,this_ccy8,this_ccy9,this_ccy10



repl all ac_desc with strt(ac_desc,'應','应')
repl all ac_desc with strt(ac_desc,'業','业')
repl all ac_desc with strt(ac_desc,'潤','润')
repl all ac_desc with strt(ac_desc,'務','务')
repl all ac_desc with strt(ac_desc,'實','实')
repl all ac_desc with strt(ac_desc,'稅','税')
repl all ac_desc with strt(ac_desc,'勞','劳')
repl all ac_desc with strt(ac_desc,'補','补')
repl all ac_desc with strt(ac_desc,'貼','贴')
repl all ac_desc with strt(ac_desc,'預','预')
repl all ac_desc with strt(ac_desc,'長','长')
repl all ac_desc with strt(ac_desc,'資','资')
repl all ac_desc with strt(ac_desc,'轉','转')
repl all ac_desc with strt(ac_desc,'產','产')
repl all ac_desc with strt(ac_desc,'價','价')
repl all ac_desc with strt(ac_desc,'損','損')
