const navigation = () => {
  return [
    {
      title: 'DASHBOARD',
      path: '/',
      icon: 'mdi:chart-line',
    },
    {
      title: 'SWAP',
      path: '/swap',
      icon: 'iconoir:coins-swap',
    },
    {
      title: 'NFT',
      icon: 'gravity-ui:picture',
      children: [
        {
          title: 'Launchpad',
          path: '/nft/launchpad',
          icon: 'mdi:rocket-launch-outline'
        },
        {
          title: 'Buy & Sell',
          path: '/nft/trade',
          icon: 'gravity-ui:shopping-cart',
        },
        {
          title: 'Auction',
          icon: 'mingcute:auction-line',
        },
        {
          title: 'Staking',
          icon: 'mingcute:pig-money-line',
        }
      ]
    },
    {
      title: 'Token',
      icon: 'gravity-ui:picture',
      children: [
        {
          title: 'Launchpad',
          icon: 'mdi:rocket-launch-outline'
        },
        {
          title: 'Trade',
          icon: 'teenyicons:candle-chart-outline',
        },
        {
          title: 'Staking',
          icon: 'mingcute:pig-money-line',
        }
      ]
    },
    {
      title: 'Documentation',
      icon: 'f7:book',
      path: '/docs',
    }
  ]
}

export default navigation
