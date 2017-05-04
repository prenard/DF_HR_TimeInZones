using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
//using Toybox.UserProfile as UserProfile;

class DF_HR_TimeInZonesView extends Ui.DataField
{
	var Device_Type;

	var App_Title;
	
	var Max_Zones_Number = 7;
	var Max_HR = 999;
	
	var Use_Garmin_Training_Zones = false;
	var Zones_Number = 0;
	var Zone_L = new [Max_Zones_Number];
	var Zone_H = new [Max_Zones_Number];
	var Zone_Time = new [Max_Zones_Number];

	var Max_Display_Timer = 10;
	var Display_Timer = 0;	

    var Loop_Index;
    var Loop_Size;
	var Loop_Value = new [Max_Display_Timer*Max_Zones_Number];

	var HR_Current = 0;
	var HR_Current_Zone = 0;

	var CustomFont_Value_Medium_1 = null;
	var CustomFont_Value_Medium_2 = null;
	var CustomFont_Value_Large_1 = null;
	
	// Layout Fields

    var DF_Title;
    var HR_Label;
    var HR_Value;
    var HR_Unit;
    var HR_Zone;
    var Z_Label;
    var Z_Value;
    var Z_Range;

		
    function initialize(Args)
    {
        DataField.initialize();

	    Device_Type = Ui.loadResource(Rez.Strings.Device);

		var Z_H = new [Max_Zones_Number+1];
		
		Z_H[1] 			= Args[0];
		Z_H[2] 			= Args[1];
		Z_H[3] 			= Args[2];
		Z_H[4] 			= Args[3];
		Z_H[5] 			= Args[4];
		Z_H[6] 			= Args[5];
		Display_Timer 	= Args[6];
        App_Title	 	= Args[7];
		Use_Garmin_Training_Zones = Args[8];

		if (Use_Garmin_Training_Zones)
		{
			var Sport = UserProfile.getCurrentSport();
			//System.println("Sport = " + Sport);
			var Garmin_HR_Zones_Array = UserProfile.getHeartRateZones(Sport);
			//for (var i = 0; i < Garmin_HR_Zones_Array.size() ; ++i)
       		//{
			//	System.println("HR_Zones_Array " + i + " - Zone " + Garmin_HR_Zones_Array[i]);
			//}
			Zones_Number = Garmin_HR_Zones_Array.size() -1;
			Zone_L[0] = 0;
			Zone_H[0] = Garmin_HR_Zones_Array[1];
			Zone_H[1] = Garmin_HR_Zones_Array[2];
			Zone_H[2] = Garmin_HR_Zones_Array[3];
			Zone_H[3] = Garmin_HR_Zones_Array[4];
			Zone_H[4] = Garmin_HR_Zones_Array[5];
			for (var i = 1; i < Zones_Number ; ++i)
       		{
				Zone_L[i] = Zone_H[i-1] + 1;
			}
		}
		else
		{
			var Last_Zone = false;
			for (var i = 1; i < Max_Zones_Number ; ++i)
    	   	{
				if (i == 1)
				{
					Zone_L[Zones_Number] = 0;
				}
				else
				{
					Zone_L[Zones_Number] = Zone_H[Zones_Number-1] + 1;
				}
				if ((Z_H[i] == 0) and !(Last_Zone))
				{
					Zone_H[Zones_Number] = Max_HR;
					Last_Zone = true;
					Zones_Number++;
				}
				if (Z_H[i] > 0)
				{
					Zone_H[Zones_Number] = Z_H[i]; 
					Zones_Number++;
				}
				if ((i == (Max_Zones_Number - 1)) and (Z_H[i] > 0))
				{
					Zone_L[Zones_Number] = Zone_H[Zones_Number-1] + 1;
					Zone_H[Zones_Number] = Max_HR;
					Last_Zone = true;
       			}
			}
		}		
		

		Loop_Index = 0;
		for (var i = 0; i < Zones_Number ; ++i)
       	{
			Zone_Time[i] = 0;
			var j = i+1;
			//System.println("Zone " + j + " : " + Zone_L[i] + " - " + Zone_H[i]);
			for (var k = 0; k < Display_Timer; ++k)
    	   	{
    	   		Loop_Value[Loop_Index] = i;
    	   		Loop_Index++;
			}
		}
		Loop_Size = Loop_Index;
		//System.println("Loop_Size : " + Loop_Size);
		
		//for (var i = 0; i < Loop_Size ; ++i)
       	//{
		//	System.println("Display " + i + " - Zone " + Loop_Value[i]);
		//}
    }


    //! Set your layout here. Anytime the size of obscurity of
    //! the draw context is changed this will be called.
    function onLayout(dc)
    {
        View.setLayout(Rez.Layouts.MainLayout(dc));

        DF_Title = View.findDrawableById("DF_Title");
        HR_Value = View.findDrawableById("HR_Value");
        HR_Unit = View.findDrawableById("HR_Unit");
        HR_Zone = View.findDrawableById("HR_Zone");
        Z_Label = View.findDrawableById("Z_Label");
        Z_Value = View.findDrawableById("Z_Value");
        Z_Range = View.findDrawableById("Z_Range");
        
   	    HR_Unit.setText("BPM");

       //if (Device_Type.equals("edge_520") or Device_Type.equals("edge_1000"))
       if (Device_Type.equals("edge_520") or Device_Type.equals("edge_820"))
       {
			CustomFont_Value_Medium_1 = Ui.loadResource(Rez.Fonts.Font_Value_Medium_1);
			CustomFont_Value_Medium_2 = Ui.loadResource(Rez.Fonts.Font_Value_Medium_2);
			CustomFont_Value_Large_1 = Ui.loadResource(Rez.Fonts.Font_Value_Large_1);
		
			HR_Value.setFont(CustomFont_Value_Large_1);
			HR_Zone.setFont(CustomFont_Value_Medium_1);
			Z_Value.setFont(CustomFont_Value_Medium_2);
			Z_Range.setFont(CustomFont_Value_Medium_1);
			Z_Label.setFont(CustomFont_Value_Medium_1);
	   }

		//System.println(App_Title);
   	    DF_Title.setText("HR Zones");
        return true;
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and save it locally in this method.
    function compute(info)
    {
       if((info.currentHeartRate != null))
            {
				HR_Current = info.currentHeartRate;
			}
			
        if( (info.currentHeartRate != null))
        {
			for (var i = 0; i < Zones_Number ; ++i)
    	   	{
    	   		if ((Zone_L[i] <= info.currentHeartRate) and (info.currentHeartRate <= Zone_H[i]))
    	   		{
    	   			Zone_Time[i]++;
    	   			//System.println("Zone " + i + " = " + Zone_Time[i]);
       				HR_Current_Zone = i + 1;
    	   		}
        	}
        }
		//System.println("HR_Current_Zone = " + HR_Zone);
    }

    //! Display the value you computed here. This will be called
    //! once a second when the data field is visible.
    function onUpdate(dc)
    {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        DF_Title = View.findDrawableById("DF_Title");
        HR_Value = View.findDrawableById("HR_Value");
        HR_Unit = View.findDrawableById("HR_Unit");
        HR_Zone = View.findDrawableById("HR_Zone");
        Z_Label = View.findDrawableById("Z_Label");
        Z_Value = View.findDrawableById("Z_Value");
        Z_Range = View.findDrawableById("Z_Range");
        
        if (getBackgroundColor() == Gfx.COLOR_BLACK)
        {
            DF_Title.setColor(Gfx.COLOR_WHITE);
            HR_Value.setColor(Gfx.COLOR_WHITE);
            HR_Unit.setColor(Gfx.COLOR_WHITE);
            HR_Zone.setColor(Gfx.COLOR_WHITE);
            Z_Label.setColor(Gfx.COLOR_WHITE);
            Z_Value.setColor(Gfx.COLOR_WHITE);
            Z_Range.setColor(Gfx.COLOR_WHITE);
        }
        else
        {
            DF_Title.setColor(Gfx.COLOR_BLACK);
            HR_Value.setColor(Gfx.COLOR_BLACK);
            HR_Unit.setColor(Gfx.COLOR_BLACK);
            HR_Zone.setColor(Gfx.COLOR_BLACK);
            Z_Label.setColor(Gfx.COLOR_BLACK);
            Z_Value.setColor(Gfx.COLOR_BLACK);
            Z_Range.setColor(Gfx.COLOR_BLACK);
        }

		//HR_Current = 288;

		HR_Value.setText(HR_Current.toString());
		HR_Zone.setText(HR_Current_Zone.toString());

		Loop_Index = (Loop_Index + 1) % Loop_Size;
		var Zone_to_Display = Loop_Value[Loop_Index];
		var Zone_to_Display_Plus_One = Zone_to_Display + 1;

		//System.println("Zone to Display : " + Zone_to_Display);
		
		Z_Label.setText(Zone_to_Display_Plus_One.toString());

		var Value_to_Display = TimeFormat(Zone_Time[Zone_to_Display]);
        
		Z_Value.setText(Value_to_Display);

		var Range_to_Display = Zone_L[Zone_to_Display].toString() + " - " + Zone_H[Zone_to_Display].toString();
		Z_Range.setText(Range_to_Display);
		
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

    function TimeFormat(Seconds)
    {
      var Rest;
               
      var Hour   = (Seconds - Seconds % 3600) / 3600; 
      Rest = Seconds - Hour * 3600;
      var Minute = (Rest - Rest % 60) / 60;
      var Second = Rest - Minute * 60; 

      var Return_Value = Hour.format("%d") + ":" + Minute.format("%02d") + ":" + Second.format("%02d");
      return Return_Value;
    }


}
