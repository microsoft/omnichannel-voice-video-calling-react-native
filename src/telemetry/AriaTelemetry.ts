import { ariaTelemetryKey } from '../config/settings';
import { AWTEventPriority } from '../external/aria/common/Enums';
import { AWTLogManager, AWTLogger, AWTEventData } from '../external/aria/webjs/AriaSDK';
import LogLevel from '../telemetry/LogLevel';
import ScenarioType from '../telemetry/ScenarioType';

interface BaseContract {
    OrgId: string;
    OCOrgUrl: string;
    WidgetId: string;
    RequestId?: string;
    ChatId?: string;
    CallId?: string;
    Domain?: string;
    ExceptionDetails?: string;
    ElapsedTimeInMilliseconds?: string;
    ChatSDKVersion: string;
    OCe2vvSDKVersion: string;
    NPMPackagesInfo?: string;
    PlatformDetails?: string;
}

enum Renderer {
    ReactNative = 'ReactNative'
}

class AriaTelemetry {
    private static _logger: AWTLogger;
    private static _debug = false;
    private static _disable = false;

    public static initialize(key: string): void {
        /* istanbul ignore next */
        this._debug && console.log(`[AriaTelemetry][logger][initialize][custom]`);
        AriaTelemetry._logger = AWTLogManager.initialize(key);
    }

    /* istanbul ignore next */
    public static setDebug(flag: boolean): void {
        AriaTelemetry._debug = flag;
    }

    public static disable(): void {
        /* istanbul ignore next */
        this._debug && console.log(`[AriaTelemetry][disable]`);
        AriaTelemetry._disable = true;
    }

    public static info(properties: AWTEventData["properties"], scenarioType: ScenarioType = ScenarioType.EVENTS): void {
        let event = {
            name: ScenarioType.EVENTS,
            properties: {
                ...AriaTelemetry.populateBaseProperties(),
                ...AriaTelemetry.fillMobilePlatformData(),
                ...properties,
                LogLevel: LogLevel.INFO
            },
            priority: AWTEventPriority.High
        };

        /* istanbul ignore next */
        this._debug && console.log(`[AriaTelemetry][info] ${scenarioType}`);
        /* istanbul ignore next */
        this._debug && console.log(event);
        /* istanbul ignore next */
        this._debug && console.log(event.properties.Event);

        !AriaTelemetry._disable && AriaTelemetry.logger?.logEvent(event);
    }

    public static debug(properties: AWTEventData["properties"], scenarioType: ScenarioType = ScenarioType.EVENTS): void {
        let event = {
            name: ScenarioType.EVENTS,
            properties: {
                ...AriaTelemetry.populateBaseProperties(),
                ...AriaTelemetry.fillMobilePlatformData(),
                ...properties,
                LogLevel: LogLevel.DEBUG
            },
            priority: AWTEventPriority.High
        };

        /* istanbul ignore next */
        this._debug && console.log(`[AriaTelemetry][debug] ${scenarioType}`);
        /* istanbul ignore next */
        this._debug && console.log(event);
        /* istanbul ignore next */
        this._debug && console.log(event.properties.Event);

        !AriaTelemetry._disable && AriaTelemetry.logger?.logEvent(event);
    }

    public static warn(properties: AWTEventData["properties"], scenarioType: ScenarioType = ScenarioType.EVENTS): void {
        let event = {
            name: ScenarioType.EVENTS,
            properties: {
                ...AriaTelemetry.populateBaseProperties(),
                ...AriaTelemetry.fillMobilePlatformData(),
                ...properties,
                LogLevel: LogLevel.WARN,
            },
            priority: AWTEventPriority.High
        };

        /* istanbul ignore next */
        this._debug && console.log(`[AriaTelemetry][warn] ${scenarioType}`);
        /* istanbul ignore next */
        this._debug && console.log(event);
        /* istanbul ignore next */
        this._debug && console.log(event.properties.Event);

        !AriaTelemetry._disable && AriaTelemetry.logger?.logEvent(event);
    }

    public static error(properties: AWTEventData["properties"], scenarioType: ScenarioType = ScenarioType.EVENTS): void {
        let event = {
            name: ScenarioType.EVENTS,
            properties: {
                ...AriaTelemetry.populateBaseProperties(),
                ...AriaTelemetry.fillMobilePlatformData(),
                ...properties,
                LogLevel: LogLevel.ERROR
            },
            priority: AWTEventPriority.High
        };

        /* istanbul ignore next */
        this._debug && console.log(`[AriaTelemetry][error] ${scenarioType}`);
        /* istanbul ignore next */
        this._debug && console.log(event);
        /* istanbul ignore next */
        this._debug && console.log(event.properties.Event);

        !AriaTelemetry._disable && AriaTelemetry.logger?.logEvent(event);
    }

    public static log(properties: AWTEventData["properties"], scenarioType: ScenarioType = ScenarioType.EVENTS): void {
        let event = {
            name: ScenarioType.EVENTS,
            properties: {
                ...AriaTelemetry.populateBaseProperties(),
                ...AriaTelemetry.fillMobilePlatformData(),
                ...properties,
                LogLevel: LogLevel.LOG
            },
            priority: AWTEventPriority.High
        };

        /* istanbul ignore next */
        this._debug && console.log(`[AriaTelemetry][log] ${scenarioType}`);
        /* istanbul ignore next */
        this._debug && console.log(event);
        /* istanbul ignore next */
        this._debug && console.log(event.properties.Event);

        !AriaTelemetry._disable && AriaTelemetry.logger?.logEvent(event);
    }

    private static get logger(): AWTLogger {
        if (!AriaTelemetry._logger) {
            /* istanbul ignore next */
            this._debug && console.log(`[AriaTelemetry][logger][initialize]`);
            AriaTelemetry._logger = AWTLogManager.initialize(ariaTelemetryKey);
        }
        return AriaTelemetry._logger;
    }

    private static populateBaseProperties(): BaseContract {
        return {
            OrgId: '',
            OCOrgUrl: '',
            WidgetId: '',
            RequestId: '',
            ChatId: '',
            CallId: '',
            Domain: '',
            ExceptionDetails: '',
            ElapsedTimeInMilliseconds: '',
            ChatSDKVersion: require('@microsoft/omnichannel-chat-sdk/package.json').version, // eslint-disable-line @typescript-eslint/no-var-requires
            OCe2vvSDKVersion: require('@microsoft/omnichannel-voice-video-calling-react-native/package.json').version, // eslint-disable-line @typescript-eslint/no-var-requires
            PlatformDetails: ''
        };
    }

    private static fillMobilePlatformData() {
        const platformData: any = {}; // eslint-disable-line @typescript-eslint/no-explicit-any
        const platformDetails: any = {}; // eslint-disable-line @typescript-eslint/no-explicit-any

        try {
            const ReactNative = require('react-native'); // eslint-disable-line @typescript-eslint/no-var-requires
            const Platform = ReactNative.Platform;

            platformDetails.Renderer = Renderer.ReactNative;

            platformData.DeviceInfo_OsVersion = Platform.Version;
            platformDetails.DeviceInfo_OsVersion = Platform.Version;

            if (Platform.OS.toLowerCase() === 'android') {
                platformData.DeviceInfo_OsName = 'Android';
                platformDetails.DeviceInfo_OsName = 'Android'
            } else if (Platform.OS.toLowerCase() === 'ios') {
                platformData.DeviceInfo_OsName = 'iOS';
                platformDetails.DeviceInfo_OsName = 'iOS'
            } else {
                platformData.DeviceInfo_OsName = `${Platform.OS}`;
                platformDetails.DeviceInfo_OsName = `${Platform.OS}`;
            }

            /* istanbul ignore next */
            this._debug && console.log(`[AriaTelemetry][fillMobilePlatformData][${platformData.DeviceInfo_OsName}]`);
        } catch {
            /* istanbul ignore next */
            this._debug && console.log("[AriaTelemetry][fillMobilePlatformData][Web]");
        }

        platformData.PlatformDetails = JSON.stringify(platformDetails); // Fallback if unable to overwrite Aria's default properties
        return platformData;
    }
}

export default AriaTelemetry;