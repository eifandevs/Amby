<template>
  <div class="base">
    <div class="content">
      <div>
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10 tar">
        <div class="message system">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="send-message">
        <div class="wrapper">
          <input type="text" id="text">
          <button v-on:click="send">send</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Report',
  props: {
    msg: String
  },
  data: function () {
    return {
      counter: 0
    }
  },
  methods: {
    send: function () {
      this.counter = this.counter + 1
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.base {
  display: block;
  margin: 0px;
}

.mt10 {
  margin-top: 10px;
}
.tal {
  text-align: left;
}
.tar {
  text-align: right;
}

.content {
  margin: 10px;
}

.message {
  display: inline-block;
  color: #333;
  background: #fff;
  border: 2px solid #5F4B8B;
  line-height: 1.3em;
}
.message.user {
  border-radius: 30px 30px 30px 0px;
}
.message.system {
  border-radius: 30px 30px 0px 30px;
}
.data {
  margin: 10px;
}

.send-message {
  position: fixed;
  left: 10px;
  width: calc(100% - 20px);
  bottom: 10px;
}
.wrapper {
  display: flex;
}
.wrapper input[type="text"] {
  background: gray;
  flex: 1 1 auto;
}

</style>
