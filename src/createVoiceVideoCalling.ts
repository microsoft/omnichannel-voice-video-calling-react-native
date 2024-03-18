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
    this.scenarioMarker = new ScenarioMarker(this.omnichannelConfig);
    this.requestId = uuidv4();
    this.telemetry = createTelemetry(this.debug);
    this.scenarioMarker.useTelemetry(this.telemetry);
    telemetrySDKConfig?.disable && this.telemetry?.disable();

    if (telemetrySDKConfig?.ariaTelemetryKey) {
      this.telemetry?.initialize(telemetrySDKConfig?.ariaTelemetryKey);
    }

    this.emitter = Platform.OS === 'android' ? new NativeEventEmitter(NativeModules.ReactNativeEventEmitter) : undefined;
    this.registerScenarioMarkerEventHandlers();
    this.askPermissions();
    console.log("[VoiceVideoCallingProxy][constructor]");
  }

  public setDebug(flag: boolean): void {
    this.debug = flag;
  }

  private askPermissions(): void {
    console.log("[VoiceVideoCallingProxy][askPermissions]");
    if (Platform.OS === 'android') {
      this.proxy.askPermissions();
    }
  }

  public initialize(params: IVoiceVideoCallingParams): void {
    this.scenarioMarker.startScenario(TelemetryEvent.InitializeE2VVSDK, {
      RequestId: this.requestId,
      ChatId: params.chatToken?.chatId || ''
    });

    if (params.callingToken && params.chatToken?.token && params.chatToken?.chatId) {
      console.log("[VoiceVideoCallingProxy][initialize]");
      this.callingParams = params;
      this.proxy.initialize(params.callingToken, this.requestId);
      this.scenarioMarker.completeScenario(TelemetryEvent.InitializeE2VVSDK, {
        RequestId: this.requestId,
        ChatId: params.chatToken?.chatId || ''
      });
    }
    else {
      this.scenarioMarker.failScenario(TelemetryEvent.InitializeE2VVSDK, {
        RequestId: this.requestId,
        ChatId: params.chatToken?.chatId || '',
        ExceptionDetails: "Voice/Video calling SDK load failed due to incorrect parameters"
      })
    }
  }

  // Other methods remain unchanged

}

const createVoiceVideoCalling = (omnichannelConfig: OmnichannelConfig,  telemetrySDKConfig: TelemetrySDKConfig = defaultTelemetrySDKConfig): VoiceVideoCallingProxy => {
  validateOmnichannelConfig(omnichannelConfig);
  return new VoiceVideoCallingProxy(omnichannelConfig, telemetrySDKConfig);
}

export default createVoiceVideoCalling;
