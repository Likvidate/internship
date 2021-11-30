<template>
    <div style="text-align: center; position: absolute">
        <a-input v-model="inputText"/>
        <a-button @click="Test(inputText)">Test openssl</a-button>
        <a-input v-model="outputText" />
        <a-button @click="GenPKey()">Gen Pkey</a-button>
    </div>
</template>

<script>
export default {
  data: function () {
    return {
      inputText: null,
      outputText: null
    }
  },
  methods: {
    Test (input) {
      this.$rpc.call('certificateGeneration', 'genCA', { text: input }).then((resp) => {
        this.outputText = resp.text
      })
    },
    GenPKey () {
      this.$rpc.call('certificateGeneration', 'GenPKey', { test: 'text' }).then((resp) => {
        console.log(resp)
      })
    }
  }
}
</script>
