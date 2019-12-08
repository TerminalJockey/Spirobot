############################################################################
###                               Spirobot                               ###
###    Dumps dns records from dnsdumpster, pings results to identify     ###
### valid servers, then crawls through the robots.txt file of main host  ###
###      looking for any misconfigured or exposed endpoints.             ###
### Finally outputs endpoints and response codes. Grep for 200 for fun!  ###
###    Use only for education and authorized research                    ###
###                -- MrBreadcrumbs / TerminalJockey                     ###
############################################################################

enter domain to pull from dnsdumpster.com, then attempt to locate endpoints by
scanning dns records for any directories in the robots.txt file.

# ToDo:
add more dns records, current dnsdumpster is limited to ~100 results limiting 
effectiveness. 
Formatting could use improvement
adding flags for optional functionality, only check for certain response codes etc
add threading!!!!!

# Dependencies:
curl

I am always open to improvements, suggestions, and willing to learn.
Anyone may modify this to your hearts content, if you credit then great, if
not no worries!

 Hack the planet!
