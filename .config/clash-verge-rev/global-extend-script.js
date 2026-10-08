const DIRECT_RULES = ['DOMAIN-SUFFIX,qoder.com,DIRECT', 'DOMAIN,clash.razord.top,DIRECT', 'DOMAIN,yacd.haishan.me,DIRECT'];

const PROXY_GROUP = {
  'Nice cloud': 'Nice Cloud',
  一元机场: '一元机场',
  鸡场: '🚀 节点选择',
};

const CURATED_CHAIN = [
  'DOMAIN,anyrouter.top,{P}',
  'RULE-SET,community-direct,DIRECT',
  'RULE-SET,service-direct,DIRECT',
  'RULE-SET,mirror-direct,DIRECT',
  'RULE-SET,transfer-proxy,{P}',
  'RULE-SET,service-proxy,{P}',
  'RULE-SET,mirror-proxy,{P}',
  'RULE-SET,private,DIRECT',
  'RULE-SET,reject,REJECT',
  'RULE-SET,icloud,DIRECT',
  'RULE-SET,apple,{P}',
  'RULE-SET,proxy,{P}',
  'RULE-SET,direct,DIRECT',
  'RULE-SET,lancidr,DIRECT',
  'RULE-SET,cncidr,DIRECT',
  'RULE-SET,telegramcidr,{P}',
  'RULE-SET,google,{P}',
  'RULE-SET,applications,DIRECT',
  'RULE-SET,manga,DIRECT',
  'RULE-SET,video,DIRECT',
  'RULE-SET,steam-cn,DIRECT',
  'RULE-SET,steam,DIRECT',
  'RULE-SET,cdn,{P}',
  'RULE-SET,applications-direct,DIRECT',
  'RULE-SET,applications-proxy,{P}',
  'RULE-SET,applications-reject,REJECT',
  'RULE-SET,adobe,REJECT',
  'GEOIP,LAN,DIRECT',
  'GEOIP,CN,DIRECT',
];

function main(config, profileName) {
  var rules = Array.isArray(config.rules) ? config.rules : [];
  var existing = {};
  rules.forEach(function (r) {
    existing[r] = true;
  });

  var fresh = DIRECT_RULES.filter(function (r) {
    return !existing[r];
  });

  var group = PROXY_GROUP[profileName];
  if (!group) {
    config.rules = fresh.concat(rules);
    return config;
  }

  if (!existing[CURATED_CHAIN[0].split('{P}').join(group)]) {
    var chain = CURATED_CHAIN.map(function (r) {
      return r.split('{P}').join(group);
    });
    fresh = fresh.concat(chain);
  }

  config.rules = fresh.concat(rules);
  return config;
}

