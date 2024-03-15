// ** MUI Imports
import Grid from '@mui/material/Grid'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Typography from '@mui/material/Typography'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import { styled } from '@mui/material/styles'

// ** Icon Imports
import Icon from 'src/@core/components/icon'

// ** Custom Component Import
import CardStatisticsVertical from 'src/@core/components/card-statistics/card-stats-vertical'

// ** Styled Component Import
import Image from 'next/image'
import PriceChart from './PriceChart'

const DashboardView = () => {
    return (
        <Grid container spacing={6} className='match-height'>
            <Grid item xs={12} md={4}>
                <Card sx={{ position: 'relative' }}>
                    <CardContent>
                        <Typography variant='h6' sx={{ display: 'flex' }} >
                            Trade and Earn{' '}
                            <Image
                                src='/images/coins/com.svg' width={30} height={32} alt='com'
                            />
                        </Typography>
                        <Typography variant='body2' sx={{ mb: 3.25 }}>
                            Get $COM as Reward
                        </Typography>
                        <Typography variant='h5' sx={{ fontWeight: 600, color: 'primary.main' }}>
                            $42.8k
                        </Typography>
                        <Typography variant='body2' sx={{ mb: 3.25 }}>
                            Monthly Reward
                        </Typography>
                        <Button size='small' variant='contained'>
                            Trade Now
                        </Button>
                        <Image
                            src='/images/cards/trophy.png' width={212} height={280} alt='trophy'
                            style={{
                                right: 22,
                                bottom: 0,
                                width: 106,
                                height: 140,
                                position: 'absolute',
                            }}
                        />
                    </CardContent>
                    </Card>
            </Grid>

            <Grid item xs={12} md={8}>
                <Grid container spacing={6}>
                    <Grid item xs={6} sm={4}>
                        <CardStatisticsVertical
                            stats='$13.4k'
                            color='success'
                            trendNumber='+38%'
                            title='Trading Volume'
                            chipText='Last 24h'
                            icon={<Icon icon='mdi:currency-usd' />}
                        />
                        
                    </Grid>

                    <Grid item xs={6} sm={4}>
                        <CardStatisticsVertical
                            stats='155k'
                            color='primary'
                            trendNumber='+22%'
                            title='Total Sales'
                            chipText='Last 24h'
                            icon={<Icon icon='mdi:cart-plus' />}
                        />
                    </Grid>

                    <Grid item xs={12} sm={4}>
                        <CardStatisticsVertical
                            stats='$13.4M'
                            color='secondary'
                            trendNumber='+38%'
                            title='Total Value Locked'
                            chipText='Last 24h'
                            icon={<Icon icon='clarity:lock-line' />}
                        />
                    </Grid>
                </Grid>
            </Grid>
            
            <Grid item xs={12}>
                <PriceChart />
            </Grid>
        </Grid>
  )
};

export default DashboardView;
