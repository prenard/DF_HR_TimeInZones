// 
// Prod id =
// Dev id  = 906b14cd7e8e42d0b40b066335721498
//
// History:
//
// 2018-02-08: Version 1.10
//
//      * Add HR Graph
//
// 2018-01-19: Version 1.05
//
//		* CIQ 2.42
//		* Fix 1030 display
//
// 2017-12-28: Version 1.04
//
//		* CIQ 2.41 to support Edge 1030
//      * 1030 support
//

using Toybox.Application as App;

class DF_HR_TimeInZonesApp extends App.AppBase
{

    function initialize()
    {
        AppBase.initialize();
   		System.println("Application Start - Total Memory = " + System.getSystemStats().totalMemory + " / Used Memory = " + System.getSystemStats().usedMemory);
    }

    //! onStart() is called on application start up
    function onStart(state)
    {
    }

    //! onStop() is called when your application is exiting
    function onStop(state)
    {
    }

    //! Return the initial view of your application here
    function getInitialView()
    {
		var Args = new [8];

		Args[0]	= readPropertyKeyInt("Z1_H",100);
		Args[1]	= readPropertyKeyInt("Z2_H",120);
		Args[2]	= readPropertyKeyInt("Z3_H",140);
		Args[3] = readPropertyKeyInt("Z4_H",160);
		Args[4] = readPropertyKeyInt("Display_Timer",2);
		Args[5] = getProperty("DF_Title");
		Args[6] = getProperty("Use_Garmin_Training_Zones");
		Args[7] = readPropertyKeyInt("Graph_Timer",4);
			
        return [ new DF_HR_TimeInZonesView(Args) ];

    }

	function readPropertyKeyInt(key,thisDefault)
	{
		var value = getProperty(key);
        if(value == null || !(value instanceof Number))
        {
        	if(value != null)
        	{
            	value = value.toNumber();
        	}
        	else
        	{
                value = thisDefault;
        	}
		}
		return value;
	}


}