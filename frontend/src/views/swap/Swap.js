// ** React Imports
import { useState } from 'react'

// ** MUI Imports
import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import Button from '@mui/material/Button'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'
import IconButton from '@mui/material/IconButton'
import InputAdornment from '@mui/material/InputAdornment'
import Collapse from '@mui/material/Collapse'
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';

// ** Icon Imports
import Icon from 'src/@core/components/icon'

// ** Hooks Imports
import { MenuItem, Select } from '@mui/material'
import Image from 'next/image'
import PriceChart from './PriceChart'
import ApexChartWrapper from 'src/@core/styles/libs/react-apexcharts'

const SwapView = () => {
  const [showChart, setShowChart] = useState(true);

  const theme = useTheme();
  const mdUp = useMediaQuery(theme.breakpoints.up('md'));

  const coins = [
    {
      name: 'Bitcoin',
      symbol: 'BTC',
      image: '/images/coins/Bitcoin.svg'
    },
    {
      name: 'BSC',
      symbol: 'BNB',
      image: '/images/coins/BSC.svg'
    },
    {
      name: 'Commune AI',
      symbol: 'COM',
      image: '/images/coins/com.svg'
    },
    {
      name: 'Cosmos',
      symbol: 'ATOM',
      image: '/images/coins/Cosmos.png'
    },
    {
      name: 'Ethereum',
      symbol: 'ETH',
      image: '/images/coins/Ethereum.png'
    },
    {
      name: 'Kusama',
      symbol: 'KSM',
      image: '/images/coins/Kusama.png'
    },
    {
      symbol: 'DOT',
      image: '/images/coins/Polkadot.svg'
    },
    {
      name: 'Polygon',
      symbol: 'MATIC',
      image: '/images/coins/Polygon.png'
    },
    {
      name: 'Solana',
      symbol: 'SOL',
      image: '/images/coins/Solana.png'
    },
    {
      name: 'Sui',
      symbol: 'SUI',
      image: '/images/coins/Sui.png'
    },
  ];

  return (
    <Box sx={{ display: 'flex', flexDirection: { md: 'row', xs: 'column' } }}>
      <Card>
        <CardHeader
          title='SWAP'
          action={
            <Box sx={{ display: 'flex', alignItems: 'center' }}>
              <IconButton
                size='small'
                aria-label='reload'
                // onClick={}
                sx={{ mr: 2, color: 'text.secondary', boxShadow: '0 26px 58px 0 rgba(0, 0, 0, .42), 0 5px 14px 0 rgba(0, 0, 0, .18)' }}
              >
                <Icon icon='material-symbols:history' fontSize={20} />
              </IconButton>

              <IconButton
                size='small'
                aria-label='close'
                sx={{ color: 'text.secondary', boxShadow: '0 26px 58px 0 rgba(0, 0, 0, .42), 0 5px 14px 0 rgba(0, 0, 0, .18)' }}
                onClick={() => setShowChart(!showChart)}
              >
                <Icon icon='mdi:chart-line' fontSize={20} />
              </IconButton>
            </Box>
          }
        />
        <CardContent
          sx={{
            '& > a': { mt: 4, fontWeight: 500, mb: 4, fontSize: '0.75rem', color: 'primary.main', textDecoration: 'none' },
          }}
        >
          <Box sx={{ p: 2, borderRadius: 1, boxShadow: '0px 3px 8px rgba(0, 0, 0, 0.24)', mb: 4 }}>
            <Box
              sx={{ display: 'flex', justifyContent: 'space-between', mb: 4 }}
            >
              <Typography variant='body2' sx={{ color: 'text.primary' }}>
                FROM
              </Typography>

              <Box sx={{ display: 'flex' }}>
                <Typography variant='body2' sx={{ color: 'text.primary', display: 'flex' }}>
                  BALANCE 0
                </Typography>

                <Typography variant='body2' sx={{ color: '#479aef', pl: 1 }}>
                  $0.00
                </Typography>
              </Box>
            </Box>

            <Box
              sx={{ display: 'flex', justifyContent: 'space-between', mb: 4, minWidth: 280 }}
            >
              <TextField
                type='number'
                label='You pay'
                size='small'
                sx={{ width: '100%' }}
                InputLabelProps={{ shrink: true }}
                InputProps={{
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Select
                        defaultValue='BTC'
                        displayEmpty inputProps={{ 'aria-label': 'Without label' }}
                        size='small'
                        sx={{ '.MuiOutlinedInput-notchedOutline': { border: '0px !important' } }}
                      >
                        {
                          coins.map((coin, index) => (
                            <MenuItem key={index} value={coin.symbol}>
                              <Box sx={{ display: 'flex', justifyContent: 'start', alignItems: 'center', width: '100%' }}>
                                <Image src={coin.image} width={24} height={24} />

                                <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'start' }}>
                                  <Typography variant='subtitle2' color='white' pl={2} lineHeight='normal'>
                                    {coin.symbol}
                                  </Typography>

                                  <Typography variant='caption' color='text.secondary' pl={2}>
                                    {coin.name}
                                  </Typography>
                                </Box>
                              </Box>
                            </MenuItem>
                          ))
                        }
                      </Select>
                    </InputAdornment>
                  ),
                  style: {
                    padding: 5
                  }
                }}
              />
            </Box>
          </Box>

          <Box sx={{ display: 'flex', justifyContent: 'center', mb: 4 }}>
            <IconButton aria-label='capture screenshot' color='secondary' size='small' sx={{ boxShadow: '0px 3px 8px rgba(0, 0, 0, 0.24)' }}>
              <Icon icon='zondicons:swap' fontSize={24} />
            </IconButton>
          </Box>

          <Box sx={{ p: 2, borderRadius: 1, boxShadow: '0px 3px 8px rgba(0, 0, 0, 0.24)', mb: 4 }}>
            <Box
              sx={{ display: 'flex', justifyContent: 'space-between', mb: 4 }}
            >
              <Typography variant='body2' sx={{ color: 'text.primary' }}>
                TO
              </Typography>

              <Box sx={{ display: 'flex' }}>
                <Typography variant='body2' sx={{ color: 'text.primary', display: 'flex' }}>
                  BALANCE 0
                </Typography>

                <Typography variant='body2' sx={{ color: '#479aef', pl: 1 }}>
                  $0.00
                </Typography>
              </Box>
            </Box>

            <Box
              sx={{ display: 'flex', justifyContent: 'space-between', mb: 4, minWidth: 280 }}
            >
              <TextField
                type='number'
                label='You receive'
                size='small'
                sx={{ width: '100%' }}
                InputLabelProps={{ shrink: true }}
                disabled
                InputProps={{
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Select
                        defaultValue='BTC'
                        displayEmpty inputProps={{ 'aria-label': 'Without label' }}
                        size='small'
                        sx={{ '.MuiOutlinedInput-notchedOutline': { border: '0px !important' } }}
                      >
                        {
                          coins.map((coin, index) => (
                            <MenuItem key={index} value={coin.symbol}>
                              <Box sx={{ display: 'flex', justifyContent: 'start', alignItems: 'center', width: '100%' }}>
                                <Image src={coin.image} width={24} height={24} />

                                <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'start' }}>
                                  <Typography variant='subtitle2' color='white' pl={2} lineHeight='normal'>
                                    {coin.symbol}
                                  </Typography>

                                  <Typography variant='caption' color='text.secondary' pl={2}>
                                    {coin.name}
                                  </Typography>
                                </Box>
                              </Box>
                            </MenuItem>
                          ))
                        }
                      </Select>
                    </InputAdornment>
                  ),
                  style: {
                    padding: 5
                  }
                }}
              />
            </Box>
          </Box>

          <Button fullWidth variant='contained' endIcon={<Icon icon='mdi:arrow-right' />}>
            Proceed to payment
          </Button>
        </CardContent>
      </Card>

      <Collapse
        in={showChart}
        orientation={ mdUp ? 'horizontal' : 'vertical' }
      >
        <Box
          sx={{
            margin: {
              xs: '12px 0 0 0',
              md: '0 0 0 12px'
            },
            width: {
              xl: 800,
              lg: 600,
              md: 500
            },
            height: 'auto'
          }}
        >
          <ApexChartWrapper>
            <PriceChart name='BTC' />
          </ApexChartWrapper>
        </Box>
      </Collapse>
    </Box>
  )
}

export default SwapView
