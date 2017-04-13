using Toybox.Application as App;

class DF_HR_TimeInZonesApp extends App.AppBase
{

    function initialize()
    {
        AppBase.initialize();
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
		var Args = new [9];
	
		Args[0] = getProperty("Z1_H");
		Args[1] = getProperty("Z2_H");
		Args[2] = getProperty("Z3_H");
		Args[3] = getProperty("Z4_H");
		Args[4] = getProperty("Z5_H");
		Args[5] = getProperty("Z6_H");
		Args[6] = getProperty("Display_Timer");
		Args[7] = getProperty("DF_Title");
		Args[8] = getProperty("Use_Garmin_Training_Zones");
		
        return [ new DF_HR_TimeInZonesView(Args) ];

    }

}