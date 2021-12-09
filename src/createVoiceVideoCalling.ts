import AriaTelemetry from "./telemetry/AriaTelemetry";
import createTelemetry from "./utils/createTelemetry";
import { NativeEventEmitter, NativeModules, Platform } from 'react-native';
import OmnichannelConfig, { TelemetrySDKConfig } from "./core/OmnichannelConfig";
import ScenarioMarker from "./telemetry/ScenarioMarker";
import ScenarioType from "./telemetry/ScenarioType";
import TelemetryEvent from './telemetry/TelemetryEvent';
import { uuidv4 } from './utils/uuid'
import validateOmnichannelConfig, { defaultTelemetrySDKConfig } from "./validators/OmnichannelConfigValidator";

const { OmnichannelVoiceVideoCallingReactNative } = NativeModules;

interface IChatToken {
  chatId?: string;
  regionGTMS?: any;
  requestId?: string;
  token?: string;
  expiresIn?: string;
  visitorId?: string;
  voiceVideoCallToken?: any;
}

interface IVoiceVideoCallingParams {
  chatToken?: IChatToken;
  callingToken?: string;
  OCClient: any;
}

class VoiceVideoCallingProxy {
  private debug: boolean;
  private proxy: any;
  private callingParams: IVoiceVideoCallingParams | undefined;
  private emitter: NativeEventEmitter | undefined;
  private scenarioMarker: ScenarioMarker;
  private omnichannelConfig: OmnichannelConfig;
  private telemetry: typeof AriaTelemetry | null = null;
  private requestId: string;

  public constructor(omnichannelConfig: OmnichannelConfig, telemetrySDKConfig: TelemetrySDKConfig = defaultTelemetrySDKConfig) {
    this.debug = true;
    this.omnichannelConfig = omnichannelConfig;
    this.proxy = OmnichannelVoiceVideoCallingReactNative;
    this.scenarioMarker = new ScenarioMarker(this.omnichannelConfig); // add omnichannel config here
    this.requestId = uuidv4();
    this.telemetry = createTelemetry(this.debug);
    this.scenarioMarker.useTelemetry(this.telemetry);
    telemetrySDKConfig?.disable && this.telemetry.disable();

    if (telemetrySDKConfig?.ariaTelemetryKey) {
      this.telemetry.initialize(telemetrySDKConfig?.ariaTelemetryKey);
    }

    this.emitter = new NativeEventEmitter(NativeModules.ReactNativeEventEmitter);
    this.registerScenarioMarkerEventHandlers();
    this.askPermissions();
    this.debug && console.log("[VoiceVideoCallingProxy][constructor]");
  }

   /* istanbul ignore next */
  public setDebug(flag: boolean): void {
    this.debug = flag;
  }

  public askPermissions(): void {
    this.debug && console.log("[VoiceVideoCallingProxy][askPermissions]");
    if (Platform.OS === 'android') {
      this.proxy.askPermissions();
    }
  }

  public initialize(params: IVoiceVideoCallingParams): void {
    this.scenarioMarker.startScenario(TelemetryEvent.InitializeE2VVSDK, {
      RequestId: this.requestId,
      ChatId: this.callingParams?.chatToken?.chatId as string
    });

    if(params.callingToken && params.chatToken?.token && params.chatToken?.chatId) {
      this.debug && console.log("[VoiceVideoCallingProxy][initialize]");
      this.callingParams = params;
      this.proxy.initialize(params.callingToken, this.requestId);
      this.scenarioMarker.completeScenario(TelemetryEvent.InitializeE2VVSDK, {
        RequestId: this.requestId,
        ChatId: this.callingParams?.chatToken?.chatId as string
      });
    }
    else {
      this.scenarioMarker.failScenario(TelemetryEvent.InitializeE2VVSDK, {
        RequestId: this.requestId,
        ChatId: this.callingParams?.chatToken?.chatId as string,
        ExceptionDetails: "Voice/Video calling SDK load failed due to incorrect parameters"
      })
    }
  }

  public async isMicrophoneMuted(): Promise<boolean> {
    this.debug && console.log("[VoiceVideoCallingProxy][isMicrophoneMuted]");
    return this.proxy.isMicrophoneMuted();
  }

  public async isRemoteVideoEnabled(): Promise<boolean> {
    this.debug && console.log("[VoiceVideoCallingProxy][isRemoteVideoEnabled]");
    return this.proxy.isRemoteVideoEnabled();
  }

  public async isLocalVideoEnabled(): Promise<boolean> {
    this.debug && console.log("[VoiceVideoCallingProxy][isLocalVideoEnabled]");
    return this.proxy.isLocalVideoEnabled();
  }

  public acceptCall(withVideo: boolean = false) {
    this.debug && console.log(`[VoiceVideoCallingProxy][acceptCall] withVideo ${withVideo}`);
    this.telemetry?.info(this.getTelemetryClientObject(withVideo ? TelemetryEvent.AcceptWithVideoButtonClicked : TelemetryEvent.AcceptWithVoiceButtonClicked), ScenarioType.EVENTS)
    this.emitter?.emit('acceptCall:withVideo');
    this.proxy.acceptCall(withVideo);
  }

  public rejectCall() {
    this.debug && console.log(`[VoiceVideoCallingProxy][rejectCall]`);
    this.debug && console.log(`[VoiceVideoCallingProxy][rejectCall]`);
    this.telemetry?.info(this.getTelemetryClientObject(TelemetryEvent.RejectCallButtonClicked), ScenarioType.EVENTS)
    this.proxy.rejectCall();
  }

  public stopCall() {
    this.debug && console.log(`[VoiceVideoCallingProxy][stopCall]`);
    this.telemetry?.info(this.getTelemetryClientObject(TelemetryEvent.StopCallButtonClicked), ScenarioType.EVENTS)
    this.proxy.stopCall();
  }

  public toggleMute() {
    this.debug && console.log(`[VoiceVideoCallingProxy][toggleMute]`);
    this.telemetry?.info(this.getTelemetryClientObject(TelemetryEvent.ToggleMuteButtonClick), ScenarioType.EVENTS)
    return this.proxy.toggleMute();
  }

  public toggleLocalVideo() {
    this.debug && console.log(`[VoiceVideoCallingProxy][toggleLocalVideo]`);
    this.telemetry?.info(this.getTelemetryClientObject(TelemetryEvent.ToggleLocalVideoButtonClick), ScenarioType.EVENTS)
    this.proxy.toggleLocalVideo();
  }

  public onCallAdded(cb: CallableFunction) {
    this.emitter?.addListener('callAdded', (response: any) => {
      this.debug && console.log('[VoiceVideoCallingProxy][Event][callAdded]');
      this.debug && console.log(response);
      cb();
    });
  }

  public onCallEnded(cb: CallableFunction) {
    this.emitter?.addListener('callEnded', (response: any) => {
      this.debug && console.log('[VoiceVideoCallingProxy][Event][callEnded]');
      this.debug && console.log(response);
      cb();
    });
  }

  public onLocalVideoStreamAdded(cb: CallableFunction) {
    this.emitter?.addListener('localVideoStreamAdded', () => {
      this.debug && console.log('[VoiceVideoCallingProxy][Event][localVideoStreamAdded]');
      cb();
    });
  }

  public onLocalVideoStreamRemoved(cb: CallableFunction) {
    this.emitter?.addListener('localVideoStreamRemoved', () => {
      this.debug && console.log('[VoiceVideoCallingProxy][Event][localVideoStreamRemoved]');
      cb();
    });
  }

  public onRemoteVideoStreamAdded(cb: CallableFunction) {
    this.emitter?.addListener('remoteVideoStreamAdded', () => {
      this.debug && console.log('[VoiceVideoCallingProxy][Event][remoteVideoStreamAdded]');
      cb();
    });
  }

  public onRemoteVideoStreamRemoved(cb: CallableFunction) {
    this.emitter?.addListener('remoteVideoStreamRemoved', () => {
      this.debug && console.log('[VoiceVideoCallingProxy][Event][remoteVideoStreamRemoved]');
      cb();
    });
  }

  public onCallDisconnected(cb: CallableFunction) {
    this.emitter?.addListener('callDisconnected', () => {
      this.debug && console.log('[VoiceVideoCallingProxy][Event][callDisconnected]');
      cb();
    });
  }

  public toggleSpeaker() {
    this.debug && console.log('[VoiceVideoCallingProxy][toggleSpeaker]');
    this.telemetry?.info(this.getTelemetryClientObject(TelemetryEvent.ToggleSpeakerButtonClick), ScenarioType.EVENTS)
    this.proxy.toggleSpeaker();
  }

  public toggleCamera() {
    this.debug && console.log('[VoiceVideoCallingProxy][toggleCamera]');
    this.telemetry?.info(this.getTelemetryClientObject(TelemetryEvent.ToggleCameraButtonClicked), ScenarioType.EVENTS)
    this.proxy.toggleCamera();
  }

  private registerScenarioMarkerEventHandlers() {
    this.debug && console.log('[VoiceVideoCallingProxy][RegisterScenarioMarker]');
    this.telemetry?.info(this.getTelemetryClientObject(TelemetryEvent.RegisterNativeScenarioMarkerInitiated), ScenarioType.EVENTS)

    this.emitter?.addListener('telemetry', (response) => {
      this.debug && console.log(`[VoiceVideoCallingProxy][Event][${response["ScenarioType"]}]`);
      if(response && response["ScenarioType"] === "ScenarioStarted" && response["EventName"]) {
        this.scenarioMarker.startScenario(response["EventName"], {
          RequestId: this.requestId,
          ChatId: this.callingParams?.chatToken?.chatId as string,
          NativePlatform: response["Platform"],
          ACSCallingVersion: response["ACSCallingVersion"],
          CallId: response["CallId"] !== undefined ? response["CallId"] : null
        })
      }
      else if(response && response["ScenarioType"] === "ScenarioCompleted" && response["EventName"]) {
        this.scenarioMarker.completeScenario(response["EventName"], {
          RequestId: this.requestId,
          ChatId: this.callingParams?.chatToken?.chatId as string,
          NativePlatform: response["Platform"],
          CallId: response["CallId"] !== undefined ? response["CallId"] : null
        })
      }
      else if(response && response["ScenarioType"] === "ScenarioFailed" && response["EventName"]) {
        this.scenarioMarker.failScenario(response["EventName"], {
          RequestId: this.requestId,
          ChatId: this.callingParams?.chatToken?.chatId as string,
          NativePlatform: response["Platform"],
          ExceptionDetails: response["ExceptionDetails"] ? response["ExceptionDetails"]: "",
          CallId: response["CallId"] !== undefined ? response["CallId"] : null
        })
      }
    });
  }

  private getTelemetryClientObject(eventName: string) {
    return {
      Event: eventName,
      OrgId: this.omnichannelConfig.orgId,
      OCOrgUrl: this.omnichannelConfig.orgUrl,
      WidgetId: this.omnichannelConfig.widgetId,
      RequestId: this.requestId,
      ChatId: this.callingParams?.chatToken?.chatId as string
    }
  }
}

const createVoiceVideoCalling = (omnichannelConfig: OmnichannelConfig,  telemetrySDKConfig: TelemetrySDKConfig = defaultTelemetrySDKConfig): VoiceVideoCallingProxy => {
  validateOmnichannelConfig(omnichannelConfig);
  return new VoiceVideoCallingProxy(omnichannelConfig, telemetrySDKConfig);
}

export default createVoiceVideoCalling;
