<template>
  <div>
    <a-button type="primary" @click="showDrawer"><a-icon type="left"/>
    </a-button>
    <a-drawer
      title="Information"
      placement="right"
      :closable="false"
      :visible="visible"
      :after-visible-change="afterVisibleChange"
      @close="onClose"
    >
          <div style="display: flex; justify-content: space-around;">
            <vuci-dashboard :percent="cpuPercentage" label="CPU usage"/>
          </div>
          <div><label>CPU time difference:</label></div>
          <div>
            <a-input v-model="cpuTime"/>
          </div>
          <div style="display: flex; justify-content: space-around;">
            <vuci-dashboard :percent="memPercentage" label="Memory usage"/>
          </div>
          <div><label>Total memory:</label></div>
          <div>
            <a-input v-model="totalMemory"/>
          </div>
          <div><label>Free memory:</label></div>
          <div>
            <a-input v-model="freeMemory"/>
          </div>
          <div><label>Used memory:</label></div>
          <div>
            <a-input v-model="usedMemory"/>
          </div>
          <div style="display: flex; justify-content: space-around;">
            <vuci-dashboard :percent="storagePercentage" label="Storage usage"/>
          </div>
          <div><label>Total storage:</label></div>
          <div>
            <a-input v-model="totalStorage"/>
          </div>
          <div><label>Free storage:</label></div>
          <div>
            <a-input v-model="freeStorage"/>
          </div>
          <div><label>Used storage:</label></div>
          <div>
            <a-input v-model="usedStorage"/>
          </div>
    </a-drawer>
  </div>
</template>
<script>
export default {
  props: {
    visible: Boolean
  },
  data: function () {
    return {
      lastCPUTime: null,
      memPercentage: 100,
      storagePercentage: 100,
      cpuPercentage: 100,
      totalMemory: null,
      freeMemory: null,
      usedMemory: null,
      totalStorage: null,
      freeStorage: null,
      usedStorage: null,
      cpuTime: null
    }
  },
  timers: {
    update: { time: 1000, autostart: true, immediate: true, repeat: true }
  },
  methods: {
    update () {
      this.$system.getInfo().then(({ memory }) => {
        this.memPercentage = Math.floor(((memory.total - memory.free) / memory.total) * 100)
        this.totalMemory = Math.floor(memory.total / 1024) + ' KB'
        this.freeMemory = Math.floor(memory.free / 1024) + ' KB'
        this.usedMemory = Math.floor((memory.total - memory.free) / 1024) + ' KB'
      })
      this.$system.getDiskInfo().then(({ root }) => {
        this.storagePercentage = Math.floor((root.used / root.total) * 100)
        this.totalStorage = Math.floor(root.total / 1024) + ' KB'
        this.freeStorage = Math.floor((root.total - root.used) / 1024) + ' KB'
        this.usedStorage = Math.floor(root.used / 1024) + ' KB'
      })
      this.$rpc.call('system', 'cpu_time').then(times => {
        if (!this.lastCPUTime) {
          this.cpuPercentage = 0
          this.lastCPUTime = times
          return
        }

        const idle1 = this.lastCPUTime[3]
        const idle2 = times[3]

        let total1 = 0
        let total2 = 0

        this.lastCPUTime.forEach(t => {
          total1 += t
        })

        times.forEach(t => {
          total2 += t
        })

        this.cpuPercentage = Math.floor(((total2 - total1 - (idle2 - idle1)) / (total2 - total1)) * 100)
        this.lastCPUTime = times
        this.cpuTime = Math.floor(total2 - total1)
      })
    },
    afterVisibleChange (val) {
      console.log('visible', val)
    },
    showDrawer () {
      this.visible = true
    },
    onClose () {
      this.visible = false
    }
  }
}
</script>
