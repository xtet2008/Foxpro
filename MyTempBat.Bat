@net Time /setsntp:210.72.145.44
@net stop w32time
@net start w32time
@w32tm -s/resync /rediscover