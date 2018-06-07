# DNAC-Assurance-on-the-go-iOS-App

The DNAC Assurance on-the-go application provides the user with a overview of the current health of the system right from the comfort of their smart phone or tablet. The application enables you to login into any cluster currently possesing DNAC and view critical information no matter where you are, enabling peace of mind 

**Installation**

In order to run the application locally on your machine you will need XCode. You can download the source code and play around with it.

1. Clone the repository
2. Navigate over to Xcode
3. (Optional)Connect your phyiscal device into your mac and select your device from the device emulator drop down. Your physical device will be located right at the top.

4. (Optional)Select an emulator of your choice within XCode
3. Hit the "Build and Run" button located on the top left


**Pod installation**

This application may require the installation of pods into your podfile. If you find your self having issues with the pod file, you can use the following steps to troubleshoot your app.

1. ```Pod init``` - Use this command if a pod file is not found within the XCode project directory. This will initialise a "Podfile" within your project.
2. Open the Podfile with any editor of your choice and enter the following cocoa pods shown below
3. After entering the required pods, use the command ```
pod install``` within the directory of the podfile to install.

After doing so, restart XCode and continue to use the .xcworkspace file to edit the project the rest of the time.

```
pod 'Alamofire', '~> 4.7'
```

```
pod 'Charts'
```

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'DNAC Dashboard' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DNAC Dashboard
        pod 'Alamofire', '~> 4.7'
        pod 'Charts'

end
```

**Device Inventory**

The Device Inventory page gives you an overview of the total number of network devices in you network based on the following family types

* Unified AP's
* Wireless Controllers
* Routers
* Switches and Hubs

![Imgur](https://i.imgur.com/tu39NuG.png)

You can interact with the pie chart and also tap into it to get a deeper insight about the devices in your network and their reachability state.

![Imgur](https://i.imgur.com/zZdS8D9.png)

**Assurance tab**

The Assurance Tab uses a variety of assurance related API's to show you the current health of both your overall network and network devices.

The assurance tab has a variety of features demoing the capabilities of the API's.

![Imgur](https://i.imgur.com/K8Z0aZc.png)

The Client Health represents the overall client health of your system currently. This includes elements such as the health of the wired and wireless clients in your system for example.

The Network Health located on the top right represents the health of monitored devices across your network such as the core switches, routers or distribution switches.

The picker view located in the centre makes a call to the site hierarchy API to gather data on the sites within the system, their type and their overall network device health score.

The horizontal bar chart located at the bottom of the screen is representative of the Network Health. It shows the current health of each family based on a percentage out of 100. For example, we can see that there are issues with wireless network devices.





