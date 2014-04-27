ClubFinder
==========



## Current Bugs

1. MyBag should update RSSI
  notification is broadcasting the wrong index.  it should broadcast t.identifer not index

2. Edit my bag does not show missing clubs

3. Mybag should disable the cell after the beacon has become unrachable
  BM should have a didDepart event notification




*To receive geofence events you must add the <QLContextPlaceConnectorDelegate> protocol to your AppDelegate.h and add a QLContextPlaceConnector property.



A. Accept Gimbal Notifications
B. Allow Location Monitoring



1. Gimbal Geofences
  Diable / Enable proximity and location monitoring

2. Proximity Monitoring with iBeacon or Gimbal
  • Scan for beacons
  • Save my beacons

3. Location monitoring
  • for saving a location to a beacon sighting 

4. CFLocationManager
  Manages 

5. Transmitter
  *name
  *identifier
  *rssi
  *previousRSSI
  *lastSighted
  *batteryLevel
  *temperature

6. Sighting
  *transmitter Transmitter
  *dateTime
  *location



# UUID and Major/Minor

Major could be the user
Minor could be each of the users golf clubs


# Understanding iBeacon Distancing

http://beekn.net/2013/11/how-to-build-ibeacon-app/
There will be delays in an event being triggered and these delays will fluctuate. 

http://stackoverflow.com/questions/20416218/understanding-ibeacon-distancing




