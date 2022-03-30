# Omnichannel Voice/Video React Native Sample App

Sample react-native app using [Omnichannel Chat SDK](https://github.com/microsoft/omnichannel-chat-sdk) with [Omnichannel Voice Video Calling React Native](https://github.com/microsoft/omnichannel-voice-video-calling-react-native)

## Prerequisites
- [React Native](https://reactnative.dev/)

## Getting Started

### 1. Configure a chat widget

If you haven't set up a chat widget yet. Please follow these instructions on:

https://docs.microsoft.com/en-us/dynamics365/omnichannel/administrator/add-chat-widget

### 2. **Copy** the widget snippet code from the **Code snippet** section and save it somewhere. It will be needed later on.

It should look similar to this:

```html
<script
    id="Microsoft_Omnichannel_LCWidget"
    src="[your-src]"
    data-app-id="[your-app-id]"
    data-org-id="[your-org-id]"
    data-org-url="[your-org-url]"
>
</script>
```

### 3. Scenario Checklist

The sample app includes the following scenarios:

- [x] Start Chat
- [x] End Chat
- [x] Accept Call
- [x] Reject Call
- [x] Stop Call
- [x] Toggle Mute
- [x] Toggle Speaker
- [x] Toggle Camera
- [x] Toggle Local Video

### 3. Run the following commands on the terminal

```
npm install
npm install node-libs-react-native --save-dev
npm install react-native-randombytes --save-dev
npm install react-native-get-random-values --save-dev
cd ios && pod install
```

### 4. Run the application with npm run android or npm run ios

### 5. Provide the org id, widget/app id, and Org URL from the chat widget script to the UI