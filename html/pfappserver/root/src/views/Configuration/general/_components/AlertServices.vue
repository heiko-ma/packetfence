<template>
  <b-alert :show="isModified" variant="warning" fade>
    <h4 class="alert-heading" v-t="'Warning'" />
    <p v-html="$t('Modifying the general configuration requires to restart the haproxy-portal service.')" />
    <base-button-service service="haproxy-portal" restart start stop
      :disabled="isLoading" class="mr-1" size="sm"/>
  </b-alert>
</template>
<script>
import {
  BaseButtonService
} from '@/components/new/'
const components = {
  BaseButtonService
}

const props = {
  isLoading: {
    type: Boolean,
    default: true
  },
  isModified: {
    type: Boolean,
    default: true
  }
}

const setup = () => {}

// @vue/component
export default {
  name: 'alert-services',
  inheritAttrs: false,
  components,
  props,
  setup
}
</script>

