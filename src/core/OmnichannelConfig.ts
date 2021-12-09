interface TelemetrySDKConfig {
    disable: boolean,
    ariaTelemetryKey?: string
}

export {
    TelemetrySDKConfig
};

export default interface OmnichannelConfig {
    orgId: string;
    orgUrl: string;
    widgetId: string;
}