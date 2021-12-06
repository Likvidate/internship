local hmac = require "openssl".hmac
local openssl = require "openssl"
local x509 = require "openssl".x509
local ext = openssl.x509.extension

local M = {}
M.cadn = {
  {commonName = 'CA'},
  {OU = "VPN server"},
  {O = "openssl"},
  {C = 'CN'}
}
M.caexts = {
  {
      object='basicConstraints',
      value='CA:true',
      critical = true,
  },
  {
    object='keyUsage',
    value='keyCertSign'
  }
}
function M.genCA (params)
    alg = 'sha256'
    key = '0123456789'
    msg = params.text
    
    local binary = hmac.hmac(alg, msg, key, true)
    local hex = hmac.hmac(alg, msg, key, false)
    params.text = hex
    return params
end

function M.to_extensions(exts)
  exts = exts or M.caexts
  local ret = {}
  for i=1, #exts do
    ret[i] = ext.new_extension(exts[i])
  end
  return ret
end

function M:new()
  local cadn = openssl.x509.name.new(M.cadn)
  local pkey = assert(openssl.pkey.new())
  local req = assert(openssl.x509.req.new(cadn, pkey))
  local cacert = openssl.x509.new(
    1,
    req
  )
  cacert:extensions(M.to_extensions())
  cacert:notbefore(os.time())
  cacert:notafter(os.time() + 3600*24*365)
  assert(cacert:sign(pkey, cacert))
  self.pkey, self.cacert = pkey, cacert
  assert(cacert:check(pkey), 'self sign check failed')
  self.crl = openssl.x509.crl.new()
  assert(self.crl:issuer(cacert:issuer()))
  assert(self.crl:version(0))
  assert(self.crl:updateTime(os.time()))
  assert(self.crl:lastUpdate(os.time()))
  assert(self.crl:nextUpdate(os.time() + 24*3600))
  local publicKey = pkey:get_public()
  local privateKey = pkey:export()
  file3 = io.open('/tmp/publickey.pem', 'w')
  file3:write(publicKey:export())
  io.close(file3)
  file2 = io.open('/tmp/Ca.pem', 'w')
  file2:write(tostring(cacert:export()))
  io.close(file2)
  file = io.open('/tmp/privateKey.pem', 'w')
  file:write(privateKey)
  io.close(file)
  return self
end

function M:get_store()
  if not self.store then
    self.store = openssl.x509.store.new({self.cacert}, {self.crl})
    assert(self.cacert:check(self.store))
  end
  return self.store
end

function M:sign(csr, extensions)
  assert(self.pkey and self.cacert, "CA not initlized")
  if type(csr)=='string' then
    csr = openssl.x509.req.read(csr)
  end

  local sn = openssl.random(16)
  sn = openssl.bn.text(sn)

  local cert = openssl.x509.new(sn, csr)
  cert:notbefore(os.time())
  if extensions then
    cert:extensions(M.to_extensions(extensions))
  end
  cert:validate(os.time(), os.time() + 3600 * 24 * 360)
  assert(cert:sign(self.pkey, self.cacert))
  return cert
end

function M:revoke(sn)
  assert(self.crl:add(sn, os.time()))
  assert(self.crl:lastUpdate(os.time()))
end
M.new()
return M
