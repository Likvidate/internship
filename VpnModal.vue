
<template>
  <a-modal :mask="false" :destroyOnClose="true" :width="620" :afterClose="refresh" v-model="tempVisible" title="Add VPN" :footer="null">
    <!-- Server modal zona -->
      <template v-if="role === 'server'">
          <vuci-form uci-config="openvpn" :card="true">
            <vuci-named-section :name="this.ConfigName" v-slot="{ s }" required>
              <vuci-form-item-switch :uci-section="s" :label="'Enable'" name="enable"/>
              <vuci-form-item-select :uci-section="s" :label="'Authentication'" name="_auth" :options="authentications" @change="handleChange"/>
              <template v-if="ConfigAuth === 'skey'">
                <vuci-form-item-input :label="'Local IP'" rules="ip4addr" :uci-section="s" name="local_ip" required/>
                <vuci-form-item-input :label="'Remote IP'" rules="ip4addr" :uci-section="s" name="remote_ip" required/>
                <vuci-form-item-input :label="'Network IP'" :rules="validateNetworkIP" :uci-section="s" name="network_ip" required/>
                <vuci-form-item-input :label="'Network netmask'" rules="netmask4" :uci-section="s" name="network_mask" required/>
                  <a-label>Static key upload:</a-label>
                <a-upload action="/upload" @change="onUpload" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileName}">
                  <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
                </a-upload>
              </template>
              <template v-if="ConfigAuth === 'tls'">
                <vuci-form-item-input :label="'network_ip'" :rules="validateNetworkIP" :uci-section="s" name="server_ip" required/>
                <vuci-form-item-input :label="'network_mask'" rules="netmask4" :uci-section="s" name="server_mask" required/>
                  <a-label>Ca upload:</a-label>
                  <br/>
                <a-upload action="/upload" @change="onUploadAuthority" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileNameAuthority}">
                  <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
                </a-upload>
                  <a-label>Server certificate upload:</a-label>
                  <br/>
                <a-upload action="/upload" @change="onUploadCertificate" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileNameCertificate}">
                  <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
                </a-upload>
                  <a-label>Server key upload:</a-label>
                  <br/>
                <a-upload action="/upload" @change="onUploadServerKey" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileNameServerKey}">
                  <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
                </a-upload>
                  <a-label>Diffle Hellman parameters file upload:</a-label>
                  <br/>
                <a-upload action="/upload" @change="onUploadHellman" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileNameHellman}">
                  <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
                </a-upload>
              </template>
            </vuci-named-section>
          </vuci-form>
      </template>
          <!-- Client modal zona -->
      <template v-if="role === 'client'">
        <vuci-form uci-config="openvpn" :card="true">
          <vuci-named-section :name="ConfigName" v-slot="{ s }" required>
            <vuci-form-item-switch :uci-section="s" :label="'Enable'" name="enable"/>
            <vuci-form-item-select :uci-section="s" :label="'Authentication'" name="_auth" :options="authentications" @change="handleChange"/>
            <template v-if="ConfigAuth === 'skey'">
              <vuci-form-item-input :label="'Remote host'" rules="ip4addr" :uci-section="s" name="remote" required/>
              <vuci-form-item-input :label="'Local IP'" rules="ip4addr" :uci-section="s" name="local_ip" required/>
              <vuci-form-item-input :label="'Remote IP'" rules="ip4addr" :uci-section="s" name="remote_ip" required/>
              <vuci-form-item-input :label="'Network IP'" :rules="validateNetworkIP" :uci-section="s" name="network_ip" required/>
              <vuci-form-item-input :label="'Network netmask'" rules="netmask4" :uci-section="s" name="network_mask" required/>
                <a-label>Static key upload:    </a-label>
              <a-upload action="/upload" @change="onUpload" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileName}">
                <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
              </a-upload>
            </template>
            <template v-if="ConfigAuth === 'tls'">
              <vuci-form-item-input :label="'Remote host'" :uci-section="s" name="remote" required/>
              <vuci-form-item-input :label="'Network IP'" :rules="validateNetworkIP" :uci-section="s" name="network_ip"/>
              <vuci-form-item-input :label="'Network netmask'" rules="netmask4" :uci-section="s" name="network_mask"/>
                <a-label>Ca upload:</a-label>
                <br/>
                <a-upload action="/upload" @change="onUploadAuthority" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileNameAuthority}">
                  <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
                </a-upload>
                <a-label>Client certificate upload:</a-label>
                <br/>
                <a-upload action="/upload" @change="onUploadCertificate" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileNameCertificate}">
                  <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
                </a-upload>
                <a-label>Client key upload:</a-label>
                <br/>
                <a-upload action="/upload" @change="onUploadClientKey" :data="{path:'/etc/vuci-upload/openvpn/' + tempFileNameClientKey}">
                  <a-button size="small" type="primary" icon="upload" @click="asignName">{{ 'Select File' }}</a-button>
                </a-upload>
            </template>
          </vuci-named-section>
        </vuci-form>
      </template>
  </a-modal>
</template>
<script>
export default {
  props: {
    tempVisible: Boolean,
    role: String,
    ConfigName: String,
    ConfigAuth: String
  },
  data: function () {
    return {
      authentications: ['skey', 'tls'],
      tempFileName: '',
      tempFileNameAuthority: '',
      tempFileNameCertificate: '',
      tempFileNameServerKey: '',
      tempFileNameClientKey: '',
      tempFileNameHellman: ''
    }
  },
  mounted () {
  },
  created () {
  },
  methods: {
    handleChange (self) {
      if (this.ConfigAuth === self.options[1]) {
        this.$rpc.call('vpn', 'delete_files', { path: this.tempFileNameAuthority })
        this.$rpc.call('vpn', 'delete_files', { path: this.tempFileNameCertificate })
        this.$rpc.call('vpn', 'delete_files', { path: this.tempFileNameServerKey })
        this.$rpc.call('vpn', 'delete_files', { path: this.tempFileNameClientKey })
        this.$rpc.call('vpn', 'delete_files', { path: this.tempFileNameHellman })
        this.$uci.reset()
        this.ConfigAuth = self.options[0]
        if (this.ConfigAuth === 'skey') {
          if (this.role === 'server') {
          }
          if (this.role === 'client') {
            this.$uci.set('openvpn', this.ConfigName, 'status', 'tmp/openvpn-status-client.log')
            this.$uci.set('openvpn', this.ConfigName, 'resolv_retry', 'infinite')
            this.$uci.set('openvpn', this.ConfigName, '_tls_auth', 0)
            this.$uci.set('openvpn', this.ConfigName, 'upload_files', 0)
          }
          this.$uci.set('openvpn', this.ConfigName, 'dev', 'tun_c_' + this.ConfigName)
          this.$uci.set('openvpn', this.ConfigName, 'verb', 5)
          this.$uci.set('openvpn', this.ConfigName, 'proto', 'udp')
          this.$uci.set('openvpn', this.ConfigName, 'cipher', 'BF-CBC')
          this.$uci.set('openvpn', this.ConfigName, 'keepalive', '10 120')
          this.$uci.set('openvpn', this.ConfigName, 'data_ciphers', 'BF-CBC')
          this.$uci.set('openvpn', this.ConfigName, 'persist_key', 1)
          this.$uci.set('openvpn', this.ConfigName, 'port', 1194)
          this.$uci.set('openvpn', this.ConfigName, 'persist_tun', 1)
        }
      } else if (this.ConfigAuth === self.options[0]) {
        this.$rpc.call('vpn', 'delete_files', { path: this.tempFileName })
        this.$uci.reset()
        this.ConfigAuth = self.options[1]
        if (this.ConfigAuth === 'tls') {
          if (this.role === 'server') {
            this.$uci.set('openvpn', this.ConfigName, '_device_cert', '/etc/certificates/server.cert.pem')
            this.$uci.set('openvpn', this.ConfigName, 'tls_server', 1)
            this.$uci.set('openvpn', this.ConfigName, 'client_config_dir', '/etc/openvpn/ccd')
          }
          if (this.role === 'client') {
            this.$uci.set('openvpn', this.ConfigName, 'status', 'tmp/openvpn-status-' + this.ConfigName + '.log')
            this.$uci.set('openvpn', this.ConfigName, 'resolv_retry', 'infinite')
            this.$uci.set('openvpn', this.ConfigName, '_tls_auth', 'none')
            this.$uci.set('openvpn', this.ConfigName, 'upload_files', 0)
            this.$uci.set('openvpn', this.ConfigName, 'nobind', 1)
            this.$uci.set('openvpn', this.ConfigName, 'tls_client', 1)
            this.$uci.set('openvpn', this.ConfigName, 'client', 1)
          }
          this.$uci.set('openvpn', this.ConfigName, 'data_ciphers', 'BF-CBC')
          this.$uci.set('openvpn', this.ConfigName, 'dev', 'tun_c_' + this.ConfigName)
          this.$uci.set('openvpn', this.ConfigName, 'auth', 'sha1')
          this.$uci.set('openvpn', this.ConfigName, '_tls_auth', 'none')
          this.$uci.set('openvpn', this.ConfigName, '_device_files', 1)
          this.$uci.set('openvpn', this.ConfigName, '_tls_cipher', 'all')
          this.$uci.set('openvpn', this.ConfigName, 'verb', 5)
          this.$uci.set('openvpn', this.ConfigName, 'proto', 'udp')
          this.$uci.set('openvpn', this.ConfigName, 'cipher', 'BF-CBC')
          this.$uci.set('openvpn', this.ConfigName, 'keepalive', '10 120')
          this.$uci.set('openvpn', this.ConfigName, 'persist_key', 1)
          this.$uci.set('openvpn', this.ConfigName, 'port', 1194)
          this.$uci.set('openvpn', this.ConfigName, 'persist_tun', 1)
        }
      }
    },
    validateNetworkIP (v) {
      const ipValid = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
      if (v === '192.168.1.1') return this.$t('Remote network IP can not be the same as Router IP')
      if (!v.match(ipValid)) return this.$t('Not valid IP')
    },
    validateNetmask (v) {

    },
    asignName () {
      this.tempFileName = 'cbid.openvpn.' + this.ConfigName + '.secretstatic.key'
      this.tempFileNameAuthority = 'ca.cert.pem'
      this.tempFileNameCertificate = this.ConfigName + '.cert.pem'
      this.tempFileNameServerKey = this.ConfigName + '.key.pem'
      this.tempFileNameClientKey = this.ConfigName + '.key.pem'
      this.tempFileNameHellman = 'dh.pem'
    },
    // If upload does not work check if catalog exists in the router
    onUpload (info) {
      const file = info.file
      const status = file.status
      this.$uci.set('openvpn', this.ConfigName, 'secret', '/etc/vuci-upload/openvpn/' + this.tempFileName)
      if (status === 'uploading' || status === 'removed') return
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
      }
      if (status === 'done') {
        this.$message.success(`uploaded '${file.name}'.`)
      }
    },
    onUploadAuthority (info) {
      const file = info.file
      const status = file.status
      this.$uci.set('openvpn', this.ConfigName, 'ca', '/etc/vuci-upload/openvpn/' + this.tempFileNameAuthority)
      if (status === 'uploading' || status === 'removed') return
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
      }
      if (status === 'done') {
        this.$message.success(`uploaded '${file.name}'.`)
      }
    },
    onUploadCertificate (info) {
      const file = info.file
      const status = file.status
      this.$uci.set('openvpn', this.ConfigName, 'cert', '/etc/vuci-upload/openvpn/' + this.tempFileNameCertificate)
      if (status === 'uploading' || status === 'removed') return
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
      }
      if (status === 'done') {
        this.$message.success(`uploaded '${file.name}'.`)
      }
    },
    onUploadServerKey (info) {
      const file = info.file
      const status = file.status
      this.$uci.set('openvpn', this.ConfigName, 'key', '/etc/vuci-upload/openvpn/' + this.tempFileNameServerKey)
      if (status === 'uploading' || status === 'removed') return
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
      }
      if (status === 'done') {
        this.$message.success(`uploaded '${file.name}'.`)
      }
    },
    onUploadClientKey (info) {
      const file = info.file
      const status = file.status
      this.$uci.set('openvpn', this.ConfigName, 'key', '/etc/vuci-upload/openvpn/' + this.tempFileNameClientKey)
      if (status === 'uploading' || status === 'removed') return
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
      }
      if (status === 'done') {
        this.$message.success(`uploaded '${file.name}'.`)
      }
    },
    onUploadHellman (info) {
      const file = info.file
      const status = file.status
      this.$uci.set('openvpn', this.ConfigName, 'dh', '/etc/vuci-upload/openvpn/' + this.tempFileNameHellman)
      if (status === 'uploading' || status === 'removed') return
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
      }
      if (status === 'done') {
        this.$message.success(`uploaded '${file.name}'.`)
      }
    },
    refresh () {
      this.$message.success('VPN saved')
      this.$eventBus.$emit('modalStatus')
      this.$eventBus.$emit('callMethodInChild')
    }
  }
}
</script>
