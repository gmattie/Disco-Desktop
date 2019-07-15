package
{ 
//Imports
import developer.mattie.desktop.Preferences;
import developer.mattie.events.PreferencesEvent
import developer.mattie.events.TinkerProxyEvent;
import developer.mattie.net.TinkerProxy;
import fl.controls.Slider;
import fl.events.SliderEvent;
import fl.events.SliderEventClickTarget;
import fl.events.InteractionInputType;
import fl.motion.Color;
import fl.transitions.Tween;
import fl.transitions.TweenEvent;
import fl.transitions.easing.Regular;
import flash.desktop.NativeApplication;
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.NativeWindowDisplayState;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.Screen;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.utils.Dictionary;
import flash.utils.Timer;

//Class
public class DiscoController extends Sprite
	{
	//Constants
	private static const layoutGap:uint = 20;
	private static const collapsedRemains:uint = 10;
	private static const panelCollapseExpandSpeed:Number = 0.4;

	private static const minimizeCloseButtonAlpha:Number = 0.33;
	private static const disabledTextLinkAlpha:Number = 0.4;
	private static const powerLinkButtonAlpha:Number = 0.65;
	private static const buttonTweenSpeed:Number = 0.25;
	
	private static const loadingString:String = "Loading";
	private static const initializingString:String = "Initializing";
	private static const connectedString:String = "Connected";
	private static const connectionErrorString:String = "Connection Error";
	private static const disconnectedString:String = "Disconnected";
	
	private static const activeGlow:uint = 0x99FFFF;
	private static const errorGlow:uint = 0xFF9999;
	private static const inactiveGlow:uint = 0x000000;
	private static const inputTextBackgroundColor:uint = 0x333333;
	
	private static const windowXPref:String = "windowXPref";
	private static const windowYPref:String = "windowYPref";
	private static const devicePanelPref:String = "devicePanelPref";
	private static const settingsPanelPref:String = "settingsPanelPref";
	private static const displayPanelPref:String = "displayPanelPref";
	private static const valuePanelPref:String = "valuePanelPref";
	private static const frequencyPanelPref:String = "frequencyPanelPref";
	private static const serialPortInputPref:String = "serialPortInputPref";
	private static const baudRateInputPref:String = "baudRateInputPref";
	private static const networkAddressInputPref:String = "networkAddressInputPref";
	private static const networkPortInputPref:String = "networkPortInputPref"
	private static const redValueSliderPref:String = "redValueSliderPref";
	private static const greenValueSliderPref:String = "greenValueSliderPref";
	private static const blueValueSliderPref:String = "blueValueSliderPref";
	private static const redFrequencySliderPref:String = "redFrequencySliderPref";
	private static const greenFrequencySliderPref:String = "greenFrequencySliderPref"
	private static const blueFrequencySliderPref:String = "blueFrequencySliderPref";

	//Variables
	private var tinkerProxy:TinkerProxy = new TinkerProxy("DiscoProxy.exe", "DiscoProxy.osx");
	private var preferences:Preferences = new Preferences();
	
	private var defaults:Dictionary = new Dictionary(true);
	private var panelIsCollapsed:Dictionary = new Dictionary(true);
	private var yPositionPanel:Dictionary = new Dictionary(true);
	private var buttonIsOn:Dictionary = new Dictionary(true);
	private var buttonIsDisabled:Dictionary = new Dictionary(true);
	
	private var applicationMenu:NativeMenu;
	private var connectDeviceMenuItem:NativeMenuItem;
	private var redFrequencyMenuItem:NativeMenuItem;
	private var greenFrequencyMenuItem:NativeMenuItem;
	private var blueFrequencyMenuItem:NativeMenuItem;
	private var valueLinkMenuItem:NativeMenuItem;
	private var frequencyLinkMenuItem:NativeMenuItem;
	private var cutMenuItem:NativeMenuItem;
	private var copyMenuItem:NativeMenuItem;
	private var pasteMenuItem:NativeMenuItem;
	private var deleteMenuItem:NativeMenuItem;
	private var selectAllMenuItem:NativeMenuItem;
	private var devicePanelMenuItem:NativeMenuItem;
	private var settingsPanelMenuItem:NativeMenuItem;
	private var displayPanelMenuItem:NativeMenuItem;
	private var valuePanelMenuItem:NativeMenuItem;
	private var frequencyPanelMenuItem:NativeMenuItem;
	private var minimizeMenuItem:NativeMenuItem;
	private var restoreMenuItem:NativeMenuItem;
	
	private var panelsArray:Array = new Array();
	private var buttonsArray:Array = new Array();
	private var panelTween:Tween;
	private var buttonTween:Tween;
	private var windowCoords:Point;
	
	private var redValueInitValue:Number;
	private var greenValueInitValue:Number;
	private var blueValueInitValue:Number;
	
	private var redFrequencyInitValue:Number;
	private var greenFrequencyInitValue:Number;
	private var blueFrequencyInitValue:Number;
	
	private var redAngle:Number = 0;
	private var greenAngle:Number = 0;
	private var blueAngle:Number = 0;
	
	private var redFrequencyValue:uint;
	private var greenFrequencyValue:uint;
	private var blueFrequencyValue:uint;
	
	private var redDisplayValue:uint;
	private var greenDisplayValue:uint;
	private var blueDisplayValue:uint;

	//Flash Authoring Exported Assets
	private var connectDeviceButton:Sprite;
	private var connectDeviceButtonLight:Sprite;
	private var consoleText:TextField;
	
	private var serialPortTitle:TextField;
	private var serialPortInput:TextField;
	private var baudRateTitle:TextField;
	private var baudRateInput:TextField;
	private var networkAddressTitle:TextField;
	private var networkAddressInput:TextField;
	private var networkPortTitle:TextField;
	private var networkPortInput:TextField;	

	private var RGBDisplay:Sprite;
	private var redDisplay:Sprite;
	private var greenDisplay:Sprite;
	private var blueDisplay:Sprite;
	
	private var redValueSlider:Slider;
	private var redValueText:TextField;
	private var greenValueSlider:Slider;
	private var greenValueText:TextField;
	private var blueValueSlider:Slider;
	private var blueValueText:TextField;
	private var linkValueButton:Sprite;
	
	private var redFrequencyButton:Sprite;
	private var redFrequencyButtonLight:Sprite;
	private var redFrequencyTitle:TextField;
	private var redFrequencySlider:Slider;
	private var redFrequencyText:TextField;
	private var greenFrequencyButton:Sprite;
	private var greenFrequencyButtonLight:Sprite;
	private var greenFrequencyTitle:TextField;
	private var greenFrequencySlider:Slider;
	private var greenFrequencyText:TextField;
	private var blueFrequencyButton:Sprite;
	private var blueFrequencyButtonLight:Sprite;
	private var blueFrequencyTitle:TextField;
	private var blueFrequencySlider:Slider;
	private var blueFrequencyText:TextField;
	private var linkFrequencyButton:Sprite;

	//Constructor
	public function DiscoController()
		{
		addEventListener(Event.ADDED_TO_STAGE, init);
		}

	//Define Paths For Flash Authoring Exported Assets And Initialize Setup
	private function init(evt:Event):void
		{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		NativeApplication.nativeApplication.autoExit = false;
		NativeApplication.nativeApplication.addEventListener(Event.EXITING, applicationExitingEventHandler);
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		//Tinker Proxy Event Listeners
		tinkerProxy.addEventListener(TinkerProxyEvent.LOADING, tinkerProxyEventHandler);
		tinkerProxy.addEventListener(TinkerProxyEvent.INITIALIZING, tinkerProxyEventHandler);
		tinkerProxy.addEventListener(TinkerProxyEvent.CONNECT, tinkerProxyEventHandler);
		tinkerProxy.addEventListener(TinkerProxyEvent.DISCONNECT, tinkerProxyEventHandler);
		tinkerProxy.addEventListener(TinkerProxyEvent.ERROR, tinkerProxyEventHandler);

		//Device Panel Assets
		connectDeviceButton = devicePanel.body.connectDeviceButton;
		connectDeviceButtonLight = devicePanel.body.connectDeviceButton.light;
		consoleText = devicePanel.body.consoleText;
		
		//Settings Panel Assets
		serialPortTitle = settingsPanel.body.serialPortTitle;
		serialPortInput = settingsPanel.body.serialPortInput;
		baudRateTitle = settingsPanel.body.baudRateTitle;
		baudRateInput = settingsPanel.body.baudRateInput;
		networkAddressTitle = settingsPanel.body.networkAddressTitle;
		networkAddressInput = settingsPanel.body.networkAddressInput;
		networkPortTitle = settingsPanel.body.networkPortTitle;
		networkPortInput = settingsPanel.body.networkPortInput;
		
		//Display Panel Assets
		RGBDisplay = displayPanel.body.RGBDisplay;
		redDisplay = displayPanel.body.redDisplay;
		greenDisplay = displayPanel.body.greenDisplay;
		blueDisplay = displayPanel.body.blueDisplay
			
		//Value Panel Assets
		redValueSlider = valuePanel.body.redValueSlider;
		redValueText = valuePanel.body.redValueText;
		greenValueSlider = valuePanel.body.greenValueSlider;
		greenValueText = valuePanel.body.greenValueText;
		blueValueSlider = valuePanel.body.blueValueSlider;
		blueValueText = valuePanel.body.blueValueText;
		linkValueButton = valuePanel.body.linkValueButton;
			
		//Frequency Panel Assets
		redFrequencyButton = frequencyPanel.body.redFrequencyButton;
		redFrequencyButtonLight = frequencyPanel.body.redFrequencyButton.light;
		redFrequencyTitle = frequencyPanel.body.redFrequencyTitle;
		redFrequencySlider = frequencyPanel.body.redFrequencySlider;
		redFrequencyText = frequencyPanel.body.redFrequencyText;
		greenFrequencyButton = frequencyPanel.body.greenFrequencyButton;
		greenFrequencyButtonLight = frequencyPanel.body.greenFrequencyButton.light;
		greenFrequencyTitle = frequencyPanel.body.greenFrequencyTitle;
		greenFrequencySlider = frequencyPanel.body.greenFrequencySlider;
		greenFrequencyText = frequencyPanel.body.greenFrequencyText;
		blueFrequencyButton = frequencyPanel.body.blueFrequencyButton;
		blueFrequencyButtonLight = frequencyPanel.body.blueFrequencyButton.light;
		blueFrequencyTitle = frequencyPanel.body.blueFrequencyTitle;
		blueFrequencySlider = frequencyPanel.body.blueFrequencySlider;
		blueFrequencyText = frequencyPanel.body.blueFrequencyText;
		linkFrequencyButton = frequencyPanel.body.linkFrequencyButton;

		//Initialization Function Calls
		setApplicationLayout
			(
			devicePanel, settingsPanel, displayPanel, valuePanel, frequencyPanel
			);
						
		setSliderEventListeners	
			(
			redValueSlider, greenValueSlider, blueValueSlider,
			redFrequencySlider, greenFrequencySlider, blueFrequencySlider
			);

		setButtonEventListenersAndProperties
			(
			minimizeButton, closeButton,
			connectDeviceButton,
			redFrequencyButton, greenFrequencyButton, blueFrequencyButton,
			linkValueButton, linkFrequencyButton
			);

		setDisabledAlpha
			(
			consoleText,
			redFrequencyTitle, greenFrequencyTitle, blueFrequencyTitle,
			redFrequencyText, greenFrequencyText, blueFrequencyText,
			linkFrequencyButton
			)

		setInputTextRestrictions
			(
			[serialPortInput, "A-z0-9.\\-/"], [baudRateInput, "0-9"], [networkAddressInput, "0-9.\\-"], [networkPortInput, "0-9"]
			);

		setTabAccessibility
			(
			[serialPortInput, baudRateInput, networkAddressInput, networkPortInput],
			[devicePanel, displayPanel, valuePanel, frequencyPanel]
			);

		if	(NativeApplication.supportsMenu)
			{
			createNativeApplicationMenu();
			}
		}

	//Set Application Layout
	private function setApplicationLayout(...panels)
		{
		var element:*;
		
		//Set Initial Panel Positions
		for each	(element in panels)
					{
					//Create Panels Array
					panelsArray.push(element);
					
					//Set Standard Panels Layout
					element.x = layoutGap;
					var previousPanel:* = panelsArray[panelsArray.indexOf(element) - 1];
					yPositionPanel[element] = (element == panelsArray[0])	? element.y = layoutGap
																			: element.y = previousPanel.y + previousPanel.height + layoutGap;
					
					//Add Mouse Event Listeners To Panel Title Bars
					element.titleBar.addEventListener(MouseEvent.MOUSE_UP, titleBarMouseUpEventHandler);
					element.titleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarMouseDownEventHandler);
					}
					
		//Set Minimize And Close Button Positions
		closeButton.y = minimizeButton.y = panelsArray[0].y;
		closeButton.x = panelsArray[0].x + panelsArray[0].width - closeButton.width - 19;
		minimizeButton.x = closeButton.x - minimizeButton.width - 2;

		//Set Application Preference Defaults
		var defaults:Dictionary = new Dictionary();
		defaults[windowXPref] = Screen.mainScreen.bounds.width / 2 - stage.nativeWindow.width / 2;
		defaults[windowYPref] = Screen.mainScreen.bounds.height / 2 - (stage.nativeWindow.height - settingsPanel.body.height + collapsedRemains) / 2;
		
		defaults[devicePanelPref] = false;
		defaults[settingsPanelPref] = true; //Hidden Panel Account For In windowYPref Default Setting
		defaults[displayPanelPref] = false;
		defaults[valuePanelPref] = false;
		defaults[frequencyPanelPref] = false;

		defaults[serialPortInputPref] = (tinkerProxy.systemIsWindows) ? "COM3" : "/dev/cu.usbserial-A700dYoR";
		defaults[baudRateInputPref] = "9600";
		defaults[networkAddressInputPref] = "127.0.0.1";
		defaults[networkPortInputPref] = "5331";
		
		defaults[redValueSliderPref] = 0;
		defaults[greenValueSliderPref] = 0;
		defaults[blueValueSliderPref] = 0;
		
		defaults[redFrequencySliderPref] = 0;
		defaults[greenFrequencySliderPref] = 0;
		defaults[blueFrequencySliderPref] = 0;

		//Read & Set Object Values From Preferences File Or Defaults
		stage.nativeWindow.x = preferences.getPreference(windowXPref, defaults[windowXPref]);
		stage.nativeWindow.y = preferences.getPreference(windowYPref, defaults[windowYPref]);
		
		panelIsCollapsed[devicePanel] = preferences.getPreference(devicePanelPref, defaults[devicePanelPref]);
		panelIsCollapsed[settingsPanel] = preferences.getPreference(settingsPanelPref, defaults[settingsPanelPref]);
		panelIsCollapsed[displayPanel] = preferences.getPreference(displayPanelPref, defaults[displayPanelPref]);
		panelIsCollapsed[valuePanel] = preferences.getPreference(valuePanelPref, defaults[valuePanelPref]);
		panelIsCollapsed[frequencyPanel] = preferences.getPreference(frequencyPanelPref, defaults[frequencyPanelPref]);

		serialPortInput.text = preferences.getPreference(serialPortInputPref, defaults[serialPortInputPref]);
		baudRateInput.text = preferences.getPreference(baudRateInputPref, defaults[baudRateInputPref]);
		networkAddressInput.text = preferences.getPreference(networkAddressInputPref, defaults[networkAddressInputPref]);
		networkPortInput.text = preferences.getPreference(networkPortInputPref, defaults[networkPortInputPref]);
		
		redValueSlider.value = preferences.getPreference(redValueSliderPref, defaults[redValueSliderPref]);
		greenValueSlider.value = preferences.getPreference(greenValueSliderPref, defaults[greenValueSliderPref]);
		blueValueSlider.value = preferences.getPreference(blueValueSliderPref, defaults[blueValueSliderPref]);

		redFrequencySlider.value = preferences.getPreference(redFrequencySliderPref, defaults[redFrequencySliderPref]);
		greenFrequencySlider.value = preferences.getPreference(greenFrequencySliderPref, defaults[greenFrequencySliderPref]);
		blueFrequencySlider.value = preferences.getPreference(blueFrequencySliderPref, defaults[blueFrequencySliderPref]);

		//Reset Panel Position If Collapsed
		for each	(element in panels)
					{
					if	(panelIsCollapsed[element])
						{
						//Reset Element Position If Collapsed
						element.body.y -= (element.body.height - collapsedRemains);
						
						//Reset Positions Of Panels Following The Collapsed Element
						for each	(var panel:* in panelsArray.slice(panelsArray.indexOf(element) + 1))
									{
									panel.y -= (element.body.height - collapsedRemains);
									yPositionPanel[panel] = panel.y;
									}
									
						stage.nativeWindow.height -= (element.body.height - collapsedRemains);
						}
					}
		}
	
	//Set & Write Preferences File And Send Zero Bytes To Device Before Exiting Application
	private function applicationExitingEventHandler(evt:Event):void
		{
		if	(tinkerProxy.connected)
				{
				tinkerProxy.writeByte(0);
				tinkerProxy.writeByte(0);
				tinkerProxy.writeByte(0);
				tinkerProxy.flush();
				tinkerProxy.close();
				}
				
		preferences.setPreference(windowXPref, stage.nativeWindow.x);
		preferences.setPreference(windowYPref, stage.nativeWindow.y);
		
		preferences.setPreference(devicePanelPref, panelIsCollapsed[devicePanel]);
		preferences.setPreference(settingsPanelPref, panelIsCollapsed[settingsPanel]);
		preferences.setPreference(displayPanelPref, panelIsCollapsed[displayPanel]);
		preferences.setPreference(valuePanelPref, panelIsCollapsed[valuePanel]);
		preferences.setPreference(frequencyPanelPref, panelIsCollapsed[frequencyPanel]);
		
		preferences.setPreference(serialPortInputPref, serialPortInput.text);
		preferences.setPreference(baudRateInputPref, baudRateInput.text);
		preferences.setPreference(networkAddressInputPref, networkAddressInput.text);
		preferences.setPreference(networkPortInputPref, networkPortInput.text);
		
		preferences.setPreference(redValueSliderPref, redValueSlider.value);
		preferences.setPreference(greenValueSliderPref, greenValueSlider.value);
		preferences.setPreference(blueValueSliderPref, blueValueSlider.value);
		
		preferences.setPreference(redFrequencySliderPref, redFrequencySlider.value);
		preferences.setPreference(greenFrequencySliderPref, greenFrequencySlider.value);
		preferences.setPreference(blueFrequencySliderPref, blueFrequencySlider.value);
		
		preferences.save();
		
		NativeApplication.nativeApplication.exit();
		}
	
	//Set Slider Event Listeners
	private function setSliderEventListeners(...sliders):void
		{
		for each	(var element:* in sliders)
					{
					element.addEventListener(SliderEvent.THUMB_PRESS, sliderPressEventHandler);
					element.addEventListener(SliderEvent.CHANGE, sliderChangeEventHandler);
					element.dispatchEvent(new SliderEvent(SliderEvent.CHANGE, element.value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
					}
		}
	
	//Set Button Event Listeners
	private function setButtonEventListenersAndProperties(...buttons):void
		{
		for each	(var element:* in buttons)
					{
					buttonsArray.push(element);
					buttonIsOn[element] = false;
					buttonIsDisabled[element] = false;
					
					element.addEventListener(MouseEvent.ROLL_OVER, buttonRollOverEventHandler);
					element.addEventListener(MouseEvent.MOUSE_UP, buttonMouseUpEventHandler);
					element.addEventListener(MouseEvent.ROLL_OUT, buttonRollOutEventHandler);
					}
					
		buttonIsDisabled[linkFrequencyButton] = true;
		}
	
	//Set Disabled Alpha
	private function setDisabledAlpha(...disabledElements):void
		{
		for each	(var element:* in disabledElements)
					element.alpha = disabledTextLinkAlpha;
		}
	
	//Set Enabled Alpha
	private function setEnabledAlpha(...enabledElements):void
		{
		for each	(var element:* in enabledElements)
					element.alpha = 1.0;
		}

	//Set Input Text Field Restrictions
	private function setInputTextRestrictions(...fieldsAndRestrictions):void
		{
		for each	(var element:* in fieldsAndRestrictions)
					{
					element[0].restrict = element[1];
					element[0].backgroundColor = inputTextBackgroundColor;
					}
		}

	//Set Ordered Keyboard Tab Accessibility
	private function setTabAccessibility(tabAccessibilityIndex:Array, tabDisabledPanels:Array):void
		{
		for	(var i:int = 0; i < tabAccessibilityIndex.length; i++)
			tabAccessibilityIndex[i].tabIndex = i + 1;
			
		for each	(var element:* in tabDisabledPanels)
					element.tabChildren = false;
		}
	
	//Create Application Menu
	private function createNativeApplicationMenu():void
		{
		applicationMenu = NativeApplication.nativeApplication.menu;
	
		while	(applicationMenu.items.length > 1)
				applicationMenu.removeItemAt(applicationMenu.items.length - 1);

		//Control Submenu
		var controlMenu:NativeMenu = new NativeMenu();
		controlMenu.addEventListener(Event.DISPLAYING, controlMenuDisplayingEventHandler);
		applicationMenu.addSubmenuAt(controlMenu, 1, "Control");
		addItemsToSubmenu			(
									controlMenu,
									connectDeviceMenuItem = createMenuItem(createCallData(pushButtonHandler, connectDeviceButton), null, "d"),
									new NativeMenuItem("", true),
									redFrequencyMenuItem = createMenuItem(createCallData(pushButtonHandler, redFrequencyButton)),
									greenFrequencyMenuItem = createMenuItem(createCallData(pushButtonHandler, greenFrequencyButton)),
									blueFrequencyMenuItem = createMenuItem(createCallData(pushButtonHandler, blueFrequencyButton)),
									new NativeMenuItem("", true),
									valueLinkMenuItem = createMenuItem(createCallData(pushButtonHandler, linkValueButton), "Link Values"),
									frequencyLinkMenuItem = createMenuItem(createCallData(pushButtonHandler, linkFrequencyButton), "Link Frequencies")
									);
		
		//Edit Submenu
		var editMenu:NativeMenu = new NativeMenu();
		editMenu.addEventListener(Event.DISPLAYING, editMenuDisplayingEventHandler);
		applicationMenu.addSubmenuAt(editMenu, 2, "Edit");
		addItemsToSubmenu			(
									editMenu,
									cutMenuItem = createMenuItem(createCallData(NativeApplication.nativeApplication.cut), "Cut", "x"),
									copyMenuItem = createMenuItem(createCallData(NativeApplication.nativeApplication.copy), "Copy", "c"),
									pasteMenuItem = createMenuItem(createCallData(NativeApplication.nativeApplication.paste), "Paste", "v"),
									deleteMenuItem = createMenuItem(createCallData(NativeApplication.nativeApplication.clear), "Delete"),
									new NativeMenuItem("", true),
									selectAllMenuItem = createMenuItem(createCallData(NativeApplication.nativeApplication.selectAll), "Select All", "a")
									);
		
		//View Submenu
		var viewMenu:NativeMenu = new NativeMenu();
		viewMenu.addEventListener(Event.DISPLAYING, viewMenuDisplayingEventHandler);
		applicationMenu.addSubmenuAt(viewMenu, 3, "View");
		addItemsToSubmenu			(
									viewMenu,
									devicePanelMenuItem = createMenuItem(createCallData(pushTitleBarHandler, devicePanel), "Device Panel"),
									settingsPanelMenuItem = createMenuItem(createCallData(pushTitleBarHandler, settingsPanel), "Settings Panel"),
									displayPanelMenuItem = createMenuItem(createCallData(pushTitleBarHandler, displayPanel), "Display Panel"),
									valuePanelMenuItem = createMenuItem(createCallData(pushTitleBarHandler, valuePanel), "Value Panel"),
									frequencyPanelMenuItem = createMenuItem(createCallData(pushTitleBarHandler, frequencyPanel), "Frequency Panel")
									);
		
		//Window Submenu
		var windowMenu:NativeMenu = new NativeMenu();
		windowMenu.addEventListener(Event.DISPLAYING, windowMenuDisplayingEventHandler);
		applicationMenu.addSubmenuAt(windowMenu, 4, "Window");
		addItemsToSubmenu			(
									windowMenu,
									minimizeMenuItem = createMenuItem(createCallData(pushButtonHandler, minimizeButton), "Minimize", "m"),
									restoreMenuItem = createMenuItem(createCallData(stage.nativeWindow.restore), "Restore", "r")
									);
		}

	//Add Items To Application Submenus
	private function addItemsToSubmenu(menu:NativeMenu, ...menuItems):void
		{
		for each	(var element:* in menuItems)
					menu.addItem(element);
		}
		
	//Create Menu Items
	private function createMenuItem(itemCall:Object, itemLabel:String = null, itemKeyEquivalent:String = null, itemKeyEquivalentModifiers:Array = null):NativeMenuItem
		{
		var resultMenuItem:NativeMenuItem = new NativeMenuItem();
		resultMenuItem.data = itemCall;
		
		if (itemLabel != null)					resultMenuItem.label = itemLabel;
		if (itemKeyEquivalent != null)			resultMenuItem.keyEquivalent = itemKeyEquivalent;
		if (itemKeyEquivalentModifiers != null)	resultMenuItem.keyEquivalentModifiers = itemKeyEquivalentModifiers;
		
		resultMenuItem.addEventListener(Event.SELECT, menuItemSelectEventHandler);
		
		return resultMenuItem; 
		}
	
	//Create Menu Item Call Data
	private function createCallData(callFunctionData:*, argumentData:* = null):Object
		{
		return {callFunction:callFunctionData, argument:argumentData};
		}
				
	//Menu Item Selection Call Data Event Handler
	private function menuItemSelectEventHandler(evt:Event):void
		{
		var targetData:Object = evt.currentTarget.data;
		
		if	(targetData.argument == null)
			targetData.callFunction();
			else
			targetData.callFunction(targetData.argument);
		}
	
	//Control Menu Displaying Event Handler
	private function controlMenuDisplayingEventHandler(evt:Event):void
		{
		buttonIsOn[connectDeviceButton]		? connectDeviceMenuItem.label = "Disconnect Device"
											: connectDeviceMenuItem.label = "Connect Device";	
		buttonIsOn[redFrequencyButton]		? redFrequencyMenuItem.label = "Deactivate Red Frequency"
											: redFrequencyMenuItem.label = "Activate Red Frequency";
		buttonIsOn[greenFrequencyButton]	? greenFrequencyMenuItem.label = "Deactivate Green Frequency"
											: greenFrequencyMenuItem.label = "Activate Green Frequency";
		buttonIsOn[blueFrequencyButton]		? blueFrequencyMenuItem.label = "Deactivate Blue Frequency"
											: blueFrequencyMenuItem.label = "Activate Blue Frequency";
		buttonIsOn[linkValueButton]			? valueLinkMenuItem.checked = true
											: valueLinkMenuItem.checked = false;
		buttonIsOn[linkFrequencyButton]		? frequencyLinkMenuItem.checked = true
											: frequencyLinkMenuItem.checked = false;
												
		if	(stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)
			{
			valueLinkMenuItem.enabled = false;
			frequencyLinkMenuItem.enabled = false;
			}
			else
			{
			valueLinkMenuItem.enabled = true;
			buttonIsDisabled[linkFrequencyButton]	? frequencyLinkMenuItem.enabled = false
													: frequencyLinkMenuItem.enabled = true;
			}
		}
	
	//Edit Menu Displaying Event Handler
	private function editMenuDisplayingEventHandler(evt:Event):void
		{
		var element:*;
		
		if	(stage.focus != null && stage.focus is TextField && stage.nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED)
			for each (element in evt.currentTarget.items) element.enabled = true;
			else
			for each (element in evt.currentTarget.items) element.enabled = false;
		}
	
	//View Menu Displaying Event Handler
	private function viewMenuDisplayingEventHandler(evt:Event):void
		{
		var element:*;
		
		panelIsCollapsed[devicePanel]		? devicePanelMenuItem.checked = false
											: devicePanelMenuItem.checked = true;
		panelIsCollapsed[settingsPanel]		? settingsPanelMenuItem.checked = false
											: settingsPanelMenuItem.checked = true;
		panelIsCollapsed[displayPanel]		? displayPanelMenuItem.checked = false
											: displayPanelMenuItem.checked = true;
		panelIsCollapsed[valuePanel]		? valuePanelMenuItem.checked = false
											: valuePanelMenuItem.checked = true;
		panelIsCollapsed[frequencyPanel]	? frequencyPanelMenuItem.checked = false
											: frequencyPanelMenuItem.checked = true;
											
		if	(stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)
			for each (element in evt.currentTarget.items) element.enabled = false;
			else
			for each (element in evt.currentTarget.items) element.enabled = true;
		}
	
	//Window Menu Displaying Event Handler
	private function windowMenuDisplayingEventHandler(evt:Event):void
		{
		if	(stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)
			{
			minimizeMenuItem.enabled = false;
			restoreMenuItem.enabled = true;
			}
			else
			{
			minimizeMenuItem.enabled = true;
			restoreMenuItem.enabled = false;
			}
		}
		
	//Title Bar Mouse Down Event Handler
	private function titleBarMouseDownEventHandler(evt:MouseEvent):void
		{
		windowCoords = new Point(stage.nativeWindow.x, stage.nativeWindow.y);
		stage.nativeWindow.startMove();
		}
	
	//Title Bar Mouse Up Event Handler
	private function titleBarMouseUpEventHandler(evt:MouseEvent):void
		{
		if	(stage.nativeWindow.x == windowCoords.x && stage.nativeWindow.y == windowCoords.y)
			pushTitleBarHandler(evt.currentTarget.parent);
		}

	//Collapse & Expand Panel Tween Event Handler (Adjusts Native Window Height)
	private function pushTitleBarHandler(targetPanel:*):void
		{
		var finishProperty:Number;
		
		if	(panelTween == null || !panelTween.isPlaying)
			{
			if	(!panelIsCollapsed[targetPanel])
				finishProperty = targetPanel.body.y - targetPanel.body.height + collapsedRemains;
				else
				{
				finishProperty = targetPanel.body.y + targetPanel.body.height - collapsedRemains;
				stage.nativeWindow.height += targetPanel.body.height - collapsedRemains;
				}
			
			panelTween = new Tween(targetPanel.body, "y", Regular.easeInOut, targetPanel.body.y, finishProperty, panelCollapseExpandSpeed, true);
			
			panelTween.addEventListener(TweenEvent.MOTION_CHANGE, panelTweenMotionChangeEventHandler);
			panelTween.addEventListener(TweenEvent.MOTION_FINISH, panelTweenMotionChangeEventHandler);
			}
		}
		
	//Panel Tween Motion Change Event Handler
	private function panelTweenMotionChangeEventHandler(evt:TweenEvent):void
		{
		var targetPanel:* = evt.currentTarget.obj.parent;
		var element:*;
		
		if	(evt.type == TweenEvent.MOTION_CHANGE)
			{			
			for each	(element in panelsArray.slice(panelsArray.indexOf(targetPanel) + 1))
						(panelIsCollapsed[targetPanel])	? element.y = yPositionPanel[element] + ((targetPanel.body.height - collapsedRemains) - (targetPanel.titleBar.height - targetPanel.body.y))
														: element.y = yPositionPanel[element] + ((targetPanel.titleBar.height - targetPanel.body.y) * -1);
													
			if	(targetPanel == displayPanel && panelIsCollapsed[displayPanel])
				updateDisplays();
			}
			else
			{
			if	(!panelIsCollapsed[targetPanel])
				stage.nativeWindow.height -= targetPanel.body.height - collapsedRemains;
				
			for	each	(element in panelsArray)
						yPositionPanel[element] = element.y;
			
			panelIsCollapsed[targetPanel] = !panelIsCollapsed[targetPanel];

			panelTween.removeEventListener(TweenEvent.MOTION_CHANGE, panelTweenMotionChangeEventHandler);
			panelTween.removeEventListener(TweenEvent.MOTION_FINISH, panelTweenMotionChangeEventHandler);
			}
		}

	//Slider Thumb Press Event Handler
	private function sliderPressEventHandler(evt:SliderEvent):void
		{
		redValueInitValue = redValueSlider.value;
		greenValueInitValue = greenValueSlider.value;
		blueValueInitValue = blueValueSlider.value;
		
		redFrequencyInitValue = redFrequencySlider.value;
		greenFrequencyInitValue = greenFrequencySlider.value;
		blueFrequencyInitValue = blueFrequencySlider.value;
		}
	
	//Slider Change Event Handler
	private function sliderChangeEventHandler(evt:SliderEvent):void
		{
		switch	(evt.currentTarget)
				{
				case redValueSlider:		redValueText.text = redValueSlider.value.toString();
									
											if 	(buttonIsOn[linkValueButton]) 
												linkSliderValues	(
																	redValueSlider.value - redValueInitValue,
																	[greenValueInitValue, blueValueInitValue],
																	[greenValueSlider, blueValueSlider],
																	[greenValueText, blueValueText]
																	);
											break;
									
				case greenValueSlider:		greenValueText.text = greenValueSlider.value.toString();
									
											if 	(buttonIsOn[linkValueButton])
												linkSliderValues	(
																	greenValueSlider.value - greenValueInitValue,
																	[redValueInitValue, blueValueInitValue],
																	[redValueSlider, blueValueSlider],
																	[redValueText, blueValueText]
																	);
											break;
									
				case blueValueSlider:		blueValueText.text = blueValueSlider.value.toString();
									
											if 	(buttonIsOn[linkValueButton])
												linkSliderValues	(
																	blueValueSlider.value - blueValueInitValue,
																	[redValueInitValue, greenValueInitValue],
																	[redValueSlider, greenValueSlider],
																	[redValueText, greenValueText]
																	);
											break;
	
				case redFrequencySlider:	redFrequencyText.text = formatFrequencyValueString(redFrequencySlider.value);
											
											if 	(buttonIsOn[linkFrequencyButton])
												linkSliderValues	(
																	redFrequencySlider.value - redFrequencyInitValue,
																	[greenFrequencyInitValue, blueFrequencyInitValue],
																	[greenFrequencySlider, blueFrequencySlider],
																	[greenFrequencyText, blueFrequencyText]
																	);
											
											break;
									
				case greenFrequencySlider:	greenFrequencyText.text = formatFrequencyValueString(greenFrequencySlider.value);
									
											if 	(buttonIsOn[linkFrequencyButton])
												linkSliderValues	(
																	greenFrequencySlider.value - greenFrequencyInitValue,
																	[redFrequencyInitValue, blueFrequencyInitValue],
																	[redFrequencySlider, blueFrequencySlider],
																	[redFrequencyText, blueFrequencyText]
																	);
											break;
									
				case blueFrequencySlider:	blueFrequencyText.text = formatFrequencyValueString(blueFrequencySlider.value);
									
											if 	(buttonIsOn[linkFrequencyButton])
												linkSliderValues	(
																	blueFrequencySlider.value - blueFrequencyInitValue,
																	[redFrequencyInitValue, greenFrequencyInitValue],
																	[redFrequencySlider, greenFrequencySlider],
																	[redFrequencyText, greenFrequencyText]
																	);
				}
		
		updateDisplays();
		}	
	
	//Link Slider Values
	private function linkSliderValues(initLinkValue:Number, slaveLinkValues:Array, slaveSliders:Array, slaveValue:Array):void
		{
		for	(var i:int = 0; i < slaveSliders.length; i++)
			{
			if	(slaveSliders[i].enabled)
				{
				slaveSliders[i].value = slaveLinkValues[i] + initLinkValue;
			
				if	(slaveValue[i] == redValueText || slaveValue[i] == greenValueText || slaveValue[i] == blueValueText)
					slaveValue[i].text = slaveSliders[i].value.toString();
					else
					slaveValue[i].text = formatFrequencyValueString(slaveSliders[i].value);
				}
			}
		}
		
	//Format Slider Frequency Text
	private function formatFrequencyValueString(value:Number):String
		{
		var resultString:String = String(value / 100);
		
		switch	(resultString.length)
				{
				case 1:	resultString = resultString.concat(".00");	break;
				case 3: resultString = resultString.concat("0");
				}
		
		return resultString;
		}

	//Button Roll Over Event Handler
	private function buttonRollOverEventHandler(evt:MouseEvent):void
		{
		if	(!buttonIsOn[evt.currentTarget] && !buttonIsDisabled[evt.currentTarget])
			buttonTween = new Tween(evt.currentTarget.light, "alpha", Regular.easeInOut, evt.currentTarget.light.alpha, 1.0, buttonTweenSpeed, true);
		}
	
	//Button Roll Out Event Handler
	private function buttonRollOutEventHandler(evt:MouseEvent):void
		{
		if	(!buttonIsOn[evt.currentTarget] && !buttonIsDisabled[evt.currentTarget])
			{
			if	(evt.currentTarget is MinimizeButton || evt.currentTarget is CloseButton)
				buttonTween = new Tween(evt.currentTarget.light, "alpha", Regular.easeInOut, evt.currentTarget.light.alpha, minimizeCloseButtonAlpha, buttonTweenSpeed, true);
				
			if	(evt.currentTarget is PowerButton || evt.currentTarget is LinkButton)
				buttonTween = new Tween(evt.currentTarget.light, "alpha", Regular.easeInOut, evt.currentTarget.light.alpha, powerLinkButtonAlpha, buttonTweenSpeed, true);						
			}
		}
	
	//Button Mouse Up Event Handler
	private function buttonMouseUpEventHandler(evt:MouseEvent):void
		{
		pushButtonHandler(evt.currentTarget);
		}
	
	//Button Selection Handler Called From Mouse Up Event Handler Or Application Menu Item Selection
	private function pushButtonHandler(targetButton:*):void
		{
		switch	(targetButton)
				{
				case minimizeButton:		stage.nativeWindow.minimize();
											break;
											
				case closeButton:			NativeApplication.nativeApplication.dispatchEvent(new Event(Event.EXITING));
											break;
											
				case connectDeviceButton:	if	(!tinkerProxy.opening)
												{
												toggleConnectDeviceButton(buttonIsOn[connectDeviceButton] = !buttonIsOn[connectDeviceButton]);
												toggleButtonDisplay(buttonIsOn[connectDeviceButton], connectDeviceButton);
												}
												
											break;
				
				case redFrequencyButton:	toggleFrequencyButton(buttonIsOn[redFrequencyButton] = !buttonIsOn[redFrequencyButton], redFrequencySlider, redFrequencyTitle,	redFrequencyText);
											toggleButtonDisplay(buttonIsOn[redFrequencyButton], redFrequencyButton);
											break;
										
				case greenFrequencyButton:	toggleFrequencyButton(buttonIsOn[greenFrequencyButton] = !buttonIsOn[greenFrequencyButton], greenFrequencySlider, greenFrequencyTitle, greenFrequencyText);
											toggleButtonDisplay(buttonIsOn[greenFrequencyButton], greenFrequencyButton);
											break;
										
				case blueFrequencyButton:	toggleFrequencyButton(buttonIsOn[blueFrequencyButton] = !buttonIsOn[blueFrequencyButton], blueFrequencySlider, blueFrequencyTitle, blueFrequencyText);
											toggleButtonDisplay(buttonIsOn[blueFrequencyButton], blueFrequencyButton);
											break;
											
				case linkValueButton:		toggleButtonDisplay(buttonIsOn[linkValueButton] = !buttonIsOn[linkValueButton], linkValueButton);
											break;
										
				case linkFrequencyButton:	if	((buttonIsOn[redFrequencyButton] + buttonIsOn[greenFrequencyButton] + buttonIsOn[blueFrequencyButton]) >= 2)
												toggleButtonDisplay(buttonIsOn[linkFrequencyButton] = !buttonIsOn[linkFrequencyButton], linkFrequencyButton);
				}
		}

	//Toggle Device Button
	private function toggleConnectDeviceButton(buttonBoolean:Boolean):void
		{
		if	(buttonBoolean)
			{
			setEnabledAlpha(consoleText);
			setDisabledAlpha(serialPortTitle, serialPortInput, baudRateTitle, baudRateInput, networkAddressTitle, networkAddressInput, networkPortTitle, networkPortInput);
			serialPortInput.selectable = baudRateInput.selectable = networkAddressInput.selectable = networkPortInput.selectable = false;
			
			tinkerProxy.open(serialPortInput.text, uint(baudRateInput.text), networkAddressInput.text, uint(networkPortInput.text));
			}
			else
			{
			setDisabledAlpha(consoleText);
			setEnabledAlpha(serialPortTitle, serialPortInput, baudRateTitle, baudRateInput, networkAddressTitle, networkAddressInput, networkPortTitle, networkPortInput);
			serialPortInput.selectable = baudRateInput.selectable = networkAddressInput.selectable = networkPortInput.selectable = true;
			
			if	(tinkerProxy.connected)
				{
				tinkerProxy.writeByte(0);
				tinkerProxy.writeByte(0);
				tinkerProxy.writeByte(0);
				tinkerProxy.flush();
				tinkerProxy.close();
				}
				else
				tinkerProxyEventHandler(new TinkerProxyEvent(TinkerProxyEvent.DISCONNECT));
			}
		}

	//Toggle Frequency Buttons
	private function toggleFrequencyButton(buttonBoolean:Boolean, frequencySlider:Slider, frequencyTitleText:TextField, frequencyValueText:TextField):void
		{
		if	(buttonBoolean)
			{
			frequencySlider.enabled = true;
			setEnabledAlpha(frequencyTitleText, frequencyValueText);
			
			if	((buttonIsOn[redFrequencyButton] + buttonIsOn[greenFrequencyButton] + buttonIsOn[blueFrequencyButton]) == 1)
				addEventListener(Event.ENTER_FRAME, waveFrequencyEventHandler);
			}
			else
			{
			frequencySlider.enabled = false;
			setDisabledAlpha(frequencyTitleText, frequencyValueText);
			
			if	((buttonIsOn[redFrequencyButton] + buttonIsOn[greenFrequencyButton] + buttonIsOn[blueFrequencyButton]) == 0)
				{
				removeEventListener(Event.ENTER_FRAME, waveFrequencyEventHandler);
				updateDisplays();
				}
			}
			
		if	((buttonIsOn[redFrequencyButton] + buttonIsOn[greenFrequencyButton] + buttonIsOn[blueFrequencyButton]) <= 1)
			{
			setDisabledAlpha(linkFrequencyButton);
			buttonIsDisabled[linkFrequencyButton] = true;
			
			if	(buttonIsOn[linkFrequencyButton])
				toggleButtonDisplay(buttonIsOn[linkFrequencyButton] = !buttonIsOn[linkFrequencyButton], linkFrequencyButton);
			}
			else
			{
			setEnabledAlpha(linkFrequencyButton);
			buttonIsDisabled[linkFrequencyButton] = false;
			}
		}
	
	//Frequency Logic
	private function waveFrequencyEventHandler(Evt:Event):void
		{
		if	(buttonIsOn[redFrequencyButton])
			{
			redFrequencyValue = redValueSlider.value / 2 + Math.cos(redAngle) * redValueSlider.value / 2;		
			redAngle += redFrequencySlider.value / 100;
			}
			
		if	(buttonIsOn[greenFrequencyButton])
			{
			greenFrequencyValue = greenValueSlider.value / 2 + Math.cos(greenAngle) * greenValueSlider.value / 2;		
			greenAngle += greenFrequencySlider.value / 100;
			}
			
		if	(buttonIsOn[blueFrequencyButton])
			{
			blueFrequencyValue = blueValueSlider.value / 2 + Math.cos(blueAngle) * blueValueSlider.value / 2;		
			blueAngle += blueFrequencySlider.value / 100;
			}
			
		updateDisplays();
		}

	//Toggle Display Of Pushed Buttons
	private function toggleButtonDisplay(buttonBoolean:Boolean, buttonTarget:Object):void
		{
		if	(buttonBoolean)
			{
			buttonTarget.filters = [new GlowFilter(activeGlow, 1.0, 5.0, 5.0, 1, 3)];
			buttonTarget.light.alpha = 1.0;
			}
			else
			{
			buttonTarget.filters = [new GlowFilter(0x000000, 1.0, 5.0, 5.0, 1, 3)];
			buttonTarget.light.alpha = powerLinkButtonAlpha;
			}
		}

	//Tinker Proxy Event Handler
	private function tinkerProxyEventHandler(evt:Event):void
		{
		switch	(evt.type)
				{
				case TinkerProxyEvent.LOADING:		consoleText.text = loadingString;
													break;
													
				case TinkerProxyEvent.INITIALIZING:	consoleText.text = initializingString;
													break;
													
				case TinkerProxyEvent.CONNECT:		consoleText.text = connectedString;
													consoleText.filters = [new GlowFilter(activeGlow, 1.0, 5.0, 5.0, 1, 3)];
													updateDisplays();
													break;
													
				case TinkerProxyEvent.DISCONNECT:	consoleText.text = disconnectedString;
													consoleText.filters = [new GlowFilter(inactiveGlow, 1.0, 5.0, 5.0, 1, 3)];
													break;
													
				case TinkerProxyEvent.ERROR:		consoleText.text = connectionErrorString;
													consoleText.filters = [new GlowFilter(errorGlow, 1.0, 5.0, 5.0, 1, 3)];
				}
		}
		
	//Display Function
	private function updateDisplays():void
		{
		if	(buttonIsOn[redFrequencyButton] && redFrequencySlider.value != 0)
			redDisplayValue = redFrequencyValue;
			else
			{
			redDisplayValue = redValueSlider.value;
			redAngle = 0;
			}
			
		if	(buttonIsOn[greenFrequencyButton] && greenFrequencySlider.value != 0)
			greenDisplayValue = greenFrequencyValue;
			else
			{
			greenDisplayValue = greenValueSlider.value;
			greenAngle = 0;
			}
			
		if	(buttonIsOn[blueFrequencyButton] && blueFrequencySlider.value != 0)
			blueDisplayValue = blueFrequencyValue;
			else
			{
			blueDisplayValue = blueValueSlider.value;
			blueAngle = 0;
			}
		
		if	(displayPanel.body.y != displayPanel.titleBar.height - displayPanel.body.height + collapsedRemains)
			{
			redDisplay.transform.colorTransform = new ColorTransform(0, 0, 0, 1, redDisplayValue);
			greenDisplay.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0, greenDisplayValue);
			blueDisplay.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, blueDisplayValue);
			RGBDisplay.transform.colorTransform = new ColorTransform(0, 0, 0, 1, redDisplayValue, greenDisplayValue, blueDisplayValue, 0);
			}
		
		if	(tinkerProxy.connected)
			{
			tinkerProxy.writeByte(redDisplayValue);
			tinkerProxy.writeByte(greenDisplayValue);
			tinkerProxy.writeByte(blueDisplayValue);
			tinkerProxy.flush();
			}
		}
	}
}