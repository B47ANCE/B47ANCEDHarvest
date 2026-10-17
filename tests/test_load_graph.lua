local required={}
local api={id="farmWorks-api"}
package.preload["farmWorks/API"]=function()required.api=(required.api or 0)+1;return api end
package.preload["farmWorks/DebugInspector"]=function()required.inspector=(required.inspector or 0)+1;return{}end
package.preload["farmWorks/CalendarProbe"]=function()required.probe=(required.probe or 0)+1;return{}end

assert(dofile(arg[1])==nil,"server loader is a side-effect entrypoint")
assert(dofile(arg[2])==nil,"client loader is a side-effect entrypoint")
assert(required.api==1,"both realms must share one cached canonical API")
assert(required.inspector==1,"client loader must install the debug inspector exactly once")
assert(required.probe==1,"client loader must install the calendar probe exactly once")

package.preload["farmWorks/API"]=nil
package.preload["farmWorks/DebugInspector"]=nil
package.preload["farmWorks/CalendarProbe"]=nil
package.loaded["farmWorks/API"]=nil
package.loaded["farmWorks/DebugInspector"]=nil
package.loaded["farmWorks/CalendarProbe"]=nil
print("B47ANCEDHarvest production load-graph checks passed")
