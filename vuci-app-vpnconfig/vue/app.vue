<template>
  <div>
    <div>
      <vuci-form uciConfig="openvpn" :card="true">
        <vuci-typed-section type="openvpn" :columns="columns" :card="false">
          <template #_name="{ s }">
            <vuci-form-item-dummy :uci-section="s" name="_name"/>
          </template>
          <template #role="{ s }">
            <vuci-form-item-dummy :uci-section="s" name="role"/>
          </template>
          <template #enableText="{ s }">
            <vuci-form-item-dummy name="t" :uci-section="s" :load="Status(s)"/>
          </template>
          <template #enable="{ s }">
            <vuci-form-item-switch @click="Status(s)" :uci-section="s" name="enable"></vuci-form-item-switch>
          </template>
          <template #actions="{ s }">
          <a-button :uci-section="s" @click="EditModal(s)" size="small" type="primary">Edit</a-button>
          <a-popconfirm :uci-sectio="s" @confirm="deleteSection(s)" title="Are you sure？">
            <a-icon slot="icon" type="question-circle-o" style="color: red" />
            <a href="#">
              <a-button :uci-section="s" size="small" type="danger">Delete</a-button>
            </a>
          </a-popconfirm>
          </template>
        </vuci-typed-section>
        <vpn-modal :tempVisible="visible"  :role="TempRoleReal" :ConfigName="TempName" :ConfigAuth="Authentication"/>
      </vuci-form>
    </div>
    <div class="box">
      <a-input addonBefore="Name: " v-model="ConfigurationName"/>
      <a-select default-value="client" @change="handleChange">
        <a-select-option value="client"> Client </a-select-option>
        <a-select-option value="server"> Server </a-select-option>
      </a-select>
      <a-button @click="callModal" type="primary">Add</a-button>
    </div>
  </div>
</template>

<script>
import VpnModal from './modals/VpnModal.vue'
export default {
  components: {
    VpnModal
  },
  data: function () {
    return {
      columns: [
        { name: '_name', label: 'Name', width: 140 },
        { name: 'role', label: 'Role', width: 140 },
        { name: 'enableText', label: 'Status', width: 140 },
        { name: 'enable', label: 'Enable', width: 140 },
        { name: 'actions', label: 'Actions', width: 30 }
      ],
      visible: false,
      TempRole: 'client',
      TempName: '',
      Authentication: '',
      TempRoleReal: 'client',
      ConfigurationName: '',
      checkName: false,
      checkRole: false,
      tempAuth: 'skey',
      controlVariable: 0,
      status: '',
      ubusResponse: '',
      fileResponse: '',
      fileResponseCorrect: '',
      fileResponseNotCorrect: ''
    }
  },
  computed: {
  },
  methods: {
    checkFile (sectionName) {
      let returnValue
      return this.$rpc.call('vpnDelete', 'FileReader', { filename: '/tmp/openvpn-status-' + sectionName + '.log' }).then((promise) => {
        if (promise !== null) {
          this.b = promise.filename[4]
          if (this.b[19] > 0) {
            returnValue = 'Connected'
            return returnValue
          } else if (this.b[19] === 0) {
            returnValue = 'Disconnected'
            return returnValue
          }
        } else {
          returnValue = 'Disconnected'
          return returnValue
        }
      })
    },
    ubusServiceCall (name) {
      this.$rpc.ubus('service', 'list').then(r => {
        if (r.openvpn.instances[name].running === false) {
          this.ubusResponse = 'Inactive'
        } else {
          this.ubusResponse = 'Active'
        }
      })
    },
    Status (s) {
      switch (s.enable) {
        case '0' :
          return 'Disabled'
        case '1' :
          this.ubusServiceCall(s._name)
          if (s.role === 'server') {
            return this.ubusResponse
          } else if (s.role === 'client') {
            this.checkFile(s._name).then((resp) => {
              if (resp !== null) {
                this.fileResponse = resp
              } else {
                this.fileResponse = null
              }
            })
            if (this.fileResponse === 'Connected') {
              this.fileResponseCorrect = this.fileResponse
              return this.fileResponseCorrect
            } else {
              this.fileResponseNotCorrect = this.fileResponse
              return this.fileResponseNotCorrect
            }
          }
          break
        default:
          return 'Error'
      }
    },
    handleChange (value) {
      this.TempRole = value
    },
    EditModal (s) {
      this.TempName = s._name
      this.TempRoleReal = s.role
      this.Authentication = s._auth
      this.visible = true
    },
    deleteSection (s) {
      this.$eventBus.$emit('deleteCall', (s._name))
    },
    callModal () {
      this.controlVariable = 0
      this.TempName = this.ConfigurationName
      this.TempRoleReal = this.TempRole
      this.Authentication = this.tempAuth
      if (this.ConfigurationName === this.$uci.get('openvpn', this.ConfigurationName, '_name') || this.ConfigurationName === '') {
        this.$message.error('Name already exists')
        this.checkName = true
        return
      } else {
        this.checkName = false
      }
      if (this.TempRole === 'server') {
        this.controlVariable = 0
        this.$uci.sections('openvpn', 'openvpn').forEach(object => {
          if (object.role === 'server') {
            this.$message.error('VPN with server role already exists')
            this.controlVariable = this.controlVariable + 1
          }
        })
      }
      if (this.controlVariable > 0) {
        this.checkRole = true
      } else {
        this.checkRole = false
      }
      if (this.checkName === false && this.checkRole === false) {
        this.$spin()
        this.$uci.add('openvpn', 'openvpn', this.ConfigurationName)
        this.$uci.set('openvpn', this.ConfigurationName, '_name', this.ConfigurationName)
        this.$uci.set('openvpn', this.ConfigurationName, 'role', this.TempRole)
        this.$uci.set('openvpn', this.ConfigurationName, '_auth', this.tempAuth)
        this.$uci.save().then(() => {
          this.$uci.apply().then(() => {
            this.$spin(false)
            if (this.TempRole === 'server') {
            }
            if (this.TempRole === 'client') {
              this.$uci.set('openvpn', this.ConfigurationName, 'status', '/tmp/openvpn-status-' + this.ConfigurationName + '.log')
              this.$uci.set('openvpn', this.ConfigurationName, 'resolv_retry', 'infinite')
              this.$uci.set('openvpn', this.ConfigurationName, '_tls_auth', 0)
              this.$uci.set('openvpn', this.ConfigurationName, 'upload_files', 0)
            }
            this.$uci.set('openvpn', this.ConfigurationName, 'dev', 'tun_s_' + this.ConfigurationName)
            this.$uci.set('openvpn', this.ConfigurationName, 'verb', 5)
            this.$uci.set('openvpn', this.ConfigurationName, 'proto', 'udp')
            this.$uci.set('openvpn', this.ConfigurationName, 'cipher', 'BF-CBC')
            this.$uci.set('openvpn', this.ConfigurationName, 'keepalive', '10 120')
            this.$uci.set('openvpn', this.ConfigurationName, 'data_ciphers', 'BF-CBC')
            this.$uci.set('openvpn', this.ConfigurationName, 'persist_key', 1)
            this.$uci.set('openvpn', this.ConfigurationName, 'port', 1194)
            this.$uci.set('openvpn', this.ConfigurationName, 'persist_tun', 1)
            this.visible = true
          })
        })
      }
    }
  },
  mounted () {
    this.$eventBus.$on('modalStatus', () => {
      this.visible = false
    })
  },
  created () {
  }
}
</script>

<style>
.box {
  position: center;
  display: flex;
  box-sizing: border-box;
  flex-flow: column nowrap;
  max-width: 200px;
  min-width: 200px;
  margin: auto;
}
</style>
