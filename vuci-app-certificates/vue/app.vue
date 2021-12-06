<template>
    <div style="text-align: center; position: absolute">
        <a-input v-model="inputText"/>
        <a-button @click="Test(inputText)">Test openssl</a-button>
        <a-input v-model="outputText" />
        <a-button @click="GenPKey()">Gen Pkey</a-button>
        <form ref="download" method="POST" action="/download">
          <input v-show="true" type="text" value="/tmp/privateKey.txt" name="path"/>
        </form>
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
      try {
        this.$rpc.call('certificateGeneration', 'new').then((resp) => {
        })
      } catch (error) {
      }
    }
  }
}
</script>
