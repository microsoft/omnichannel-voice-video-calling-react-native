import { orgId, orgUrl, widgetId} from '@env';

const fetchOmnichannelConfig = () => {
  // const omnichannelConfig = {
  //   orgId,
  //   orgUrl,
  //   widgetId
  // }

  // dogfood
  // const omnichannelConfig = {
  //   orgId: "d367c413-e0b9-408b-ae1c-382499b369ae",
  //   orgUrl: "https://omnichannel-crm.omnichannelengagementhub.com",
  //   widgetId: "fa508d04-f10a-4349-9e12-336d959bfe7d"
  // }

  // // ocrpenv
  // const omnichannelConfig = {
  //   orgId: "5bf19fe1-be8b-413b-9e8e-95c4b067796e",
  //   orgUrl: "https://5bf19fe1be8b413b9e8e95c4b067796e-crm.oc.crmlivetie.com",
  //   widgetId: "1159bff3-1d61-4c0c-864c-b72187fd6464"
  // }

  // ocacschat
  // const omnichannelConfig = {
  //   orgId: "43e0c107-79ed-4bcc-b16a-037e52fa1306",
  //   orgUrl: "https://43e0c10779ed4bccb16a037e52fa1306-crm.oc.crmlivetie.com",
  //   widgetId: "4398caf9-7143-4552-8e16-9cf8915ca3e0"
  // }

  // octelephonyexternal
  // const omnichannelConfig = {
  //   orgId: "ce2a3dae-f8bd-4de9-9032-8752deb51c25",
  //   orgUrl: "https://unqce2a3daef8bd4de990328752deb51-crm.oc.crmlivetie.com",
  //   widgetId: "dd65d91b-6d10-4235-bb8f-199bf0612e01"
  // }

  // OCDAILYM0821
  // const omnichannelConfig = {
  //   orgId: "51b64923-82b4-4e8c-972d-d4b8408816a5",
  //   orgUrl: "https://unq51b6492382b44e8c972dd4b840881-crm.oc.crmlivetie.com",
  //   widgetId: "70518c89-db64-43a9-b2e5-b38b07454e06"
  // }

  // // OCDailym0827 - ACS

  const omnichannelConfig = {
    orgId: "53f5ea3c-6522-42b5-a4ae-7466566bab09",
    orgUrl: "https://unq53f5ea3c652242b5a4ae7466566ba-crm.oc.crmlivetie.com",
    widgetId: "0bc52601-cc22-4c40-9160-589ce2e78e22"
  }


  // ocdailym62hf
  // const omnichannelConfig = {
  //   orgId: "07609a4c-3a46-483e-bb3d-817974ce8e8f",
  //   orgUrl: "https://unq07609a4c3a46483ebb3d817974ce8-crm.oc.crmlivetie.com",
  //   widgetId: "3faf0d9d-2acd-4079-ae42-0fdefd0e2890"
  // }

  // ocrajateamcanary
  // const omnichannelConfig = {
  //   orgId: "b0b47a3b-8530-4292-b73b-e92f69940a99",
  //   orgUrl: "https://unqb0b47a3b85304292b73be92f69940-crm.oc.crmlivetie.com",
  //   widgetId: "18bed0bb-ae4e-486a-bcf2-9db0f8e39708"
  // }

  return omnichannelConfig;
}

export default fetchOmnichannelConfig;

// <script id="Microsoft_Omnichannel_LCWidget" src="https://oc-cdn-ocprod.azureedge.net/livechatwidget/scripts/LiveChatBootstrapper.js" data-app-id="" data-lcw-version="prod" data-org-id="d367c413-e0b9-408b-ae1c-382499b369ae" data-org-url="https://omnichannel-crm.omnichannelengagementhub.com"></script>