<template>
<div>
  <vuci-form uci-config="new_test_config" :card="true">
    <vuci-named-section name="test" v-slot="{ s }">
      <vuci-form-item-select :label="'IP address'" :uci-section="s" name="address" :options="addresses"/>
      <vuci-form-item-select :label="'Netmask'" :uci-section="s" name="netmask" :options="netmasks"/>
      <vuci-form-item-radio :uci-section="s" :label="'Netmask'" :isButton="false"  name="netmask" :options="netmasks" />
      <vuci-form-item-radio :uci-section="s" :label="'Address'" :isButton="false"  name="address" :options="addresses" />
    </vuci-named-section>
    <vuci-typed-section type="interface" :collapsible="true" v-slot="{ s }">
      <vuci-form-item-input :label="'IP address'" :uci-section="s" name="address" required/>
      <vuci-form-item-input :label="'Netmask'" :uci-section="s"  name="netmask" required/>
      <vuci-form-item-radio :uci-section="s" :label="'Netmask'" :isButton="true"  name="netmask" :options="netmasks" />
      <vuci-form-item-radio :uci-section="s" :label="'Address'" :isButton="true"  name="address" :options="addresses" />
    </vuci-typed-section>
  </vuci-form>
  <a-button @click="testclicknew"/>
  <a-input v-model="a"></a-input>
</div>
</template>
<script>
export default {
  data: function () {
    return {
      a: null,
      first_login_value_test: 'test',
      netmasks: ['255.255.255.0', '255.255.0.0', '255.0.0.0'],
      addresses: ['192.168.1.1', '192.168.1.2', '192.168.1.3']
    }
  },
  methods: {
    async testclicknew () {
      await this.$uci.load('vuci')
      this.a = this.$uci.get('vuci', 'main', 'first_login')
      console.log(this.a)
    }
  }
}
</script>
