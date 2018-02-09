using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
//using Toybox.UserProfile as UserProfile;

class DF_HR_TimeInZonesView extends Ui.DataField
{
	var Device_Type;

	var App_Title;
	
	var Max_Zones_Number = 5;
	var Max_HR = 999;
	
	var Use_Garmin_Training_Zones = false;
	var Zones_Number = 0;
	var Zone_L = new [Max_Zones_Number];
	var Zone_H = new [Max_Zones_Number];
	var Zone_Time = new [Max_Zones_Number];

	var Max_Display_Timer = 10;
	var Display_Timer = 0;
	var Graph_Timer = 0;
	
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

	// Graph Management

	var arrayColours = new [5];

	var arrayHRSize = 0;
    var arrayHRValue = new [0];
    var arrayHRZone = new [0];
    var curPos;
	var aveHRValue = 0;
	var aveHRCount = 0;

	var HRmin = 0;
	var HRmax = 0;
	var HRmid;

	var DF_Title_x = 0;
	var DF_Title_y = 0;
	var DF_Title_font = Gfx.FONT_XTINY;

	var HR_Value_x = 0;
	var HR_Value_y = 0;
	var HR_Value_font = Gfx.FONT_XTINY;

	var HR_Zone_x = 0;
	var HR_Zone_y = 0;
	var HR_Zone_font = Gfx.FONT_XTINY;

	var HR_Unit_x = 0;
	var HR_Unit_y = 0;
	var HR_Unit_font = Gfx.FONT_XTINY;

	var Z_Label_x = 0;
	var Z_Label_y = 0;
	var Z_Label_font = Gfx.FONT_XTINY;

	var Z_Value_x = 0;
	var Z_Value_y = 0;
	var Z_Value_font = Gfx.FONT_XTINY;

	var Z_Range_x = 0;
	var Z_Range_y = 0;
	var Z_Range_font = Gfx.FONT_XTINY;

	var Graph_Right_x = 0;
	var Graph_Bottom_y = 0;
		
    function initialize(Args)
    {
        DataField.initialize();

	    Device_Type = Ui.loadResource(Rez.Strings.Device);
		System.println("Device_Type = " + Device_Type);

		var Z_H = new [Max_Zones_Number - 1];
		
		Z_H[0] 			= Args[0];
		Z_H[1] 			= Args[1];
		Z_H[2] 			= Args[2];
		Z_H[3] 			= Args[3];
		Display_Timer 	= Args[4];
        App_Title	 	= Args[5];
		Use_Garmin_Training_Zones = Args[6];
		Graph_Timer 	= Args[7];

		if (Use_Garmin_Training_Zones)
		{
			var Sport = UserProfile.getCurrentSport();
			//System.println("Sport = " + Sport);
			var Garmin_HR_Zones_Array = UserProfile.getHeartRateZones(Sport);
			for (var i = 0; i < Garmin_HR_Zones_Array.size() ; ++i)
       		{
				System.println("Garmin_HR_Zones_Array " + i + " - Zone " + Garmin_HR_Zones_Array[i]);
			}
			Zones_Number = Garmin_HR_Zones_Array.size() - 2;
			Zone_L[0] = 0;
			Zone_H[0] = Garmin_HR_Zones_Array[1];
			Zone_H[1] = Garmin_HR_Zones_Array[2];
			Zone_H[2] = Garmin_HR_Zones_Array[3];
			Zone_H[3] = Garmin_HR_Zones_Array[4];
			Zone_H[4] = Garmin_HR_Zones_Array[5];
			for (var i = 1; i <= Zones_Number ; ++i)
       		{
				Zone_L[i] = Zone_H[i-1] + 1;
			}
		}
		else
		{
			var Last_Zone = false;

			Zone_L[0] = 0;
			for (var i = 0; i < Z_H.size() ; ++i)
    	   	{
				for (var j = 0; j < Zones_Number ; ++j)
       			{
					System.println("Zone " + j + " : " + Zone_L[j] + " - " + Zone_H[j]);
				}
				
				if ((Z_H[i] == 0) and (!Last_Zone))
				{
					Zone_H[Zones_Number] = Max_HR;
				}
				else
				{
					Zone_H[Zones_Number] = Z_H[i];
					Zones_Number++;
					Zone_L[Zones_Number] = Zone_H[Zones_Number-1] + 1;
					if (i == (Z_H.size() - 1))
					{
						Zone_H[Zones_Number] = Max_HR;
					}
				}
			}
		}		
		
		System.println("Zones_Number = " + Zones_Number);
		
		Loop_Index = 0;
		for (var i = 0; i <= Zones_Number ; ++i)
       	{
			Zone_Time[i] = 0;
			var j = i+1;
			System.println("Zone " + j + " : " + Zone_L[i] + " - " + Zone_H[i]);
			for (var k = 0; k < Display_Timer; ++k)
    	   	{
    	   		Loop_Value[Loop_Index] = i;
    	   		Loop_Index++;
			}
		}
		Loop_Size = Loop_Index;

		// Device Management

		switch (Device_Type)
		{
			case "edge_520":

				Graph_Right_x = 100;
				Graph_Bottom_y = 49;

				DF_Title_x = 1;
				DF_Title_y = 6;
				DF_Title_font = Gfx.FONT_XTINY;

				HR_Value_x = 85;
				HR_Value_y = 30;
				HR_Value_font = Gfx.FONT_LARGE;

				HR_Zone_x = 1;
				HR_Zone_y = 20;
				HR_Zone_font = Gfx.FONT_SMALL;

				HR_Unit_x = 90;
				HR_Unit_y = 25;
				HR_Unit_font = Gfx.FONT_XTINY;

				Z_Label_x = 97;
				Z_Label_y = 10;
				Z_Label_font = Gfx.FONT_SMALL;

				Z_Value_x = 197;
				Z_Value_y = 13;
				Z_Value_font = Gfx.FONT_MEDIUM;

				Z_Range_x = 197;
				Z_Range_y = 33;
				Z_Range_font = Gfx.FONT_MEDIUM;

				break;

			case "edge_820":

				Graph_Right_x = 195;
				Graph_Bottom_y = 49;

				DF_Title_x = 1;
				DF_Title_y = 6;
				DF_Title_font = Gfx.FONT_XTINY;

				HR_Value_x = 85;
				HR_Value_y = 30;
				HR_Value_font = Gfx.FONT_LARGE;

				HR_Zone_x = 1;
				HR_Zone_y = 20;
				HR_Zone_font = Gfx.FONT_SMALL;

				HR_Unit_x = 90;
				HR_Unit_y = 25;
				HR_Unit_font = Gfx.FONT_XTINY;

				Z_Label_x = 97;
				Z_Label_y = 10;
				Z_Label_font = Gfx.FONT_SMALL;

				Z_Value_x = 197;
				Z_Value_y = 13;
				Z_Value_font = Gfx.FONT_MEDIUM;

				Z_Range_x = 197;
				Z_Range_y = 33;
				Z_Range_font = Gfx.FONT_MEDIUM;

				break;

			case "edge_1000":

				Graph_Right_x = 230;
				Graph_Bottom_y = 75;

				DF_Title_x = 1;
				DF_Title_y = 6;
				DF_Title_font = Gfx.FONT_XTINY;

				HR_Value_x = 85;
				HR_Value_y = 30;
				HR_Value_font = Gfx.FONT_LARGE;

				HR_Zone_x = 1;
				HR_Zone_y = 20;
				HR_Zone_font = Gfx.FONT_SMALL;

				HR_Unit_x = 90;
				HR_Unit_y = 25;
				HR_Unit_font = Gfx.FONT_XTINY;

				Z_Label_x = 97;
				Z_Label_y = 10;
				Z_Label_font = Gfx.FONT_SMALL;

				Z_Value_x = 237;
				Z_Value_y = 15;
				Z_Value_font = Gfx.FONT_LARGE;

				Z_Range_x = 237;
				Z_Range_y = 45;
				Z_Range_font = Gfx.FONT_LARGE;

				break;

			case "edge_1030":

				Graph_Right_x = 270;
				Graph_Bottom_y = 90;

				DF_Title_x = 1;
				DF_Title_y = 6;
				DF_Title_font = Gfx.FONT_XTINY;

				HR_Value_x = 85;
				HR_Value_y = 30;
				HR_Value_font = Gfx.FONT_LARGE;

				HR_Zone_x = 1;
				HR_Zone_y = 20;
				HR_Zone_font = Gfx.FONT_SMALL;

				HR_Unit_x = 90;
				HR_Unit_y = 25;
				HR_Unit_font = Gfx.FONT_XTINY;

				Z_Label_x = 97;
				Z_Label_y = 10;
				Z_Label_font = Gfx.FONT_SMALL;

				Z_Value_x = 279;
				Z_Value_y = 15;
				Z_Value_font = Gfx.FONT_LARGE;

				Z_Range_x = 279;
				Z_Range_y = 45;
				Z_Range_font = Gfx.FONT_LARGE;

				break;


			default:
				break;
		}

		arrayHRSize = Graph_Right_x - 5;


		System.println("Before Array Allocation - Total Memory = " + System.getSystemStats().totalMemory + " / Used Memory = " + System.getSystemStats().usedMemory);

		for (var i = 0; i < arrayHRSize; ++i)
		{
			arrayHRValue.add(["0"]);
			arrayHRZone.add(["0"]);
			//System.println("During Array Allocation - Total Memory = " + System.getSystemStats().totalMemory + " / Used Memory = " + System.getSystemStats().usedMemory);
		}


		System.println("arrayHRValue.size()  = " + arrayHRValue.size());
		System.println("arrayHRZone.size()  = " + arrayHRZone.size());
		System.println("Graph Period = " + (arrayHRSize * Graph_Timer / 60) + " Min");
		
		
        curPos = 0;
        arrayColours = [Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLUE, Gfx.COLOR_DK_GREEN, Gfx.COLOR_ORANGE, Gfx.COLOR_DK_RED];
		HRmid = ( Zone_L[1] + (Zone_H[Zones_Number]-Zone_L[1])*0.5 ).toNumber();
        for (var i = 0; i < arrayHRValue.size(); ++i)
        {
            arrayHRValue[i] = 0;
            arrayHRZone[i] = -1;
        }

    }


    //! Set your layout here. Anytime the size of obscurity of
    //! the draw context is changed this will be called.
    function onLayout(dc)
    {
    	System.println("DC Height  = " + dc.getHeight());
      	System.println("DC Width  = " + dc.getWidth());

        View.setLayout(Rez.Layouts.MainLayout(dc));

     
       //if (Device_Type.equals("edge_520") or Device_Type.equals("edge_1000"))
       if (Device_Type.equals("edge_520") or Device_Type.equals("edge_820"))
       {
			CustomFont_Value_Medium_1 = Ui.loadResource(Rez.Fonts.Font_Value_Medium_1);
			CustomFont_Value_Medium_2 = Ui.loadResource(Rez.Fonts.Font_Value_Medium_2);
			CustomFont_Value_Large_1 = Ui.loadResource(Rez.Fonts.Font_Value_Large_1);
	   }

        return true;
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and save it locally in this method.
    function compute(info)
    {
		var HR_Zone = 0;

		if (info.currentHeartRate != null)
		{
			HR_Current = info.currentHeartRate;
			HR_Zone = GetHRZone(HR_Current);
			HR_Current_Zone = HR_Zone + 1;
		}

		if (HR_Current != null && info.elapsedTime != null && info.elapsedTime > 0)
		{

			aveHRValue = aveHRValue + HR_Current;
			aveHRCount = aveHRCount + 1;
			
			if(aveHRCount > Graph_Timer)
			{
				arrayHRValue[curPos] = (aveHRValue / aveHRCount).toNumber();
				arrayHRZone[curPos] = GetHRZone(arrayHRValue[curPos]);

				System.println("arrayHRValue[" + curPos + "]: " + arrayHRValue[curPos]);
				System.println("arrayHRZone[" + curPos + "]: " + arrayHRZone[curPos]);


				curPos = curPos + 1;
				if(curPos > arrayHRValue.size()-1)
				{
					curPos = 0;
				}
				aveHRCount = 0;
				aveHRValue = 0;
			}

			HRmin = Zone_H[0];
			HRmax = Zone_H[Zones_Number - 1];

			//HRmin = HRmid + 5;
			//HRmax = HRmid - 5;

        	for (var i = 0; i < arrayHRValue.size(); ++i)
        	{
        		if(arrayHRZone[i] >=0)
        		{
       				if(arrayHRValue[i] > HRmax)
       				{
        				HRmax = arrayHRValue[i];
        			}
        			else
        			if(arrayHRValue[i] < HRmin)
        			{
        				HRmin = arrayHRValue[i];
        			}
        		}
        	}        		

			HRmin = HRmin - 5;
			//if(HRmin < Zone_L[1] + 10) { HRmin = Zone_L[1] + 10; }  // set floor just above min HR
			HRmax = HRmax + 5;
			//if(HRmax > Zone_H[4] + 5) { HRmax = Zone_H[4] + 5; }  // clip spikes just above max HR

			// Compute time in Zones
			System.println("HR_Zone = " + HR_Zone);
			Zone_Time[HR_Zone]++;
		
        }
		//System.println("HR_Current_Zone = " + HR_Zone);
    }

    //! Display the value you computed here. This will be called
    //! once a second when the data field is visible.
    function onUpdate(dc)
    {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

		var FontDisplayColor = Gfx.COLOR_BLACK;

        Z_Range = View.findDrawableById("Z_Range");
        
        if (getBackgroundColor() == Gfx.COLOR_BLACK)
        {
            FontDisplayColor = Gfx.COLOR_WHITE;
        }
        else
        {
            FontDisplayColor = Gfx.COLOR_BLACK;
        }

		//HR_Current = 288;

		Loop_Index = (Loop_Index + 1) % Loop_Size;
		var Zone_to_Display = Loop_Value[Loop_Index];
		var Zone_to_Display_Plus_One = Zone_to_Display + 1;

		//System.println("Zone to Display : " + Zone_to_Display);

		var Value_to_Display = TimeFormat(Zone_Time[Zone_to_Display]);
        
		var Range_to_Display = Zone_L[Zone_to_Display].toString() + " - " + Zone_H[Zone_to_Display].toString();
		
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        for (var i = 0; i < arrayHRValue.size(); ++i)
        {
			//System.println("Graph: " + i);
			var ii;
			var scaling;

        	ii = curPos-1-i;
        	if(ii < 0)
        	{
        		ii = ii + arrayHRValue.size();
        	}

        	if(arrayHRZone[ii] >=0)
        	{
				scaling = (arrayHRValue[ii] - HRmin).toFloat() / (HRmax - HRmin).toFloat();
				dc.setColor(arrayColours[arrayHRZone[ii]], Gfx.COLOR_TRANSPARENT);
        		dc.drawLine(Graph_Right_x - i, Graph_Bottom_y, Graph_Right_x - i, (Graph_Bottom_y - Graph_Bottom_y * scaling).toNumber());
        	}
        }


		//HR_Current_Zone = GetHRZone(HR_Current);
		//System.println("HR_Current: " + HR_Current);
		//System.println("HR_Current_Zone: " + HR_Current_Zone);
		
		textL(dc, DF_Title_x, DF_Title_y, DF_Title_font, FontDisplayColor, "HR Zones");
		textR(dc, HR_Value_x, HR_Value_y, HR_Value_font, FontDisplayColor, HR_Current.toString());
		textL(dc, HR_Zone_x, HR_Zone_y, HR_Zone_font, FontDisplayColor, HR_Current_Zone.toString());
		textL(dc, HR_Unit_x, HR_Unit_y, HR_Unit_font, FontDisplayColor, "BPM");
		textL(dc, Z_Label_x, Z_Label_y, Z_Label_font, FontDisplayColor, Zone_to_Display_Plus_One.toString());
		textR(dc, Z_Value_x, Z_Value_y, Z_Value_font, FontDisplayColor, Value_to_Display.toString());
		textR(dc, Z_Range_x, Z_Range_y, Z_Range_font, FontDisplayColor, Range_to_Display.toString());
		
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

	function textR(dc, x, y, font, color, s)
	{
		if (s != null)
		{
			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}

	function textL(dc, x, y, font, color, s)
	{
		if (s != null)
		{
			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}


    function GetHRZone(hr)
    {
		var HR_Zone = 0;
		for (var i = 0; i < Zones_Number ; ++i)
    	{
    		if ((Zone_L[i] <= hr) and (hr <= Zone_H[i]))
    	   	{
    	   		HR_Zone = i;
    	   		return HR_Zone;
    	   	}
        }
    	return HR_Zone;
	}


}
