<template>
  <vuci-form-item-template v-bind="VuciFormItemTemplateProps">
    <a-radio-group v-model="model" @change="onChange">
      <component :is="is" v-for="(value, key) in options" :key=key :value=value >{{value}}</component>
    </a-radio-group>
  </vuci-form-item-template>
</template>

<script>
import VuciFormItemMixin from './VuciFormItemMixin'
export default {
  name: 'VuciRadio',
  mixins: [VuciFormItemMixin],
  props: {
    isButton: Boolean,
    options: Array
  },
  data: function () {
    return {
    }
  },
  computed: {
    is () {
      if (this.isButton) return 'a-radio-button'
      return 'a-radio'
    }
  },
  methods: {
    onChange (e) {
      console.log('radio checked', e.target.value)
    }
  }
}
</script>
