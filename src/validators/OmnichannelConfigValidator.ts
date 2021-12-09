import {ariaTelemetryKey} from "../config/settings";
import OmnichannelConfig, { TelemetrySDKConfig } from "../core/OmnichannelConfig";

const requiredOmnichannelConfigParams = ["orgUrl", "orgId", "widgetId"];

const defaultTelemetrySDKConfig: TelemetrySDKConfig = {
    disable: false,
    ariaTelemetryKey
};

const validateOmnichannelConfig = (omnichannelConfig: OmnichannelConfig): void => {
    if (!omnichannelConfig) {
      throw new Error(`OmnichannelConfiguration not found`);
    }

    const currentOmnichannelConfigParams = Object.keys(omnichannelConfig);
    for (const key of requiredOmnichannelConfigParams) {
      if (!currentOmnichannelConfigParams.includes(key)) {
        throw new Error(`Missing '${key}' in OmnichannelConfiguration`);
      }
    }
}

export {
  defaultTelemetrySDKConfig
};

export default validateOmnichannelConfig;