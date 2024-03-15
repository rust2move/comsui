import Grid from '@mui/material/Grid'
import NftMintCard from '../shared/NftMintCard';

const images = [
    '1.avif',
    '2.webp',
    '3.avif',
    '4.avif',
    '5.avif',
    '6.avif',
    '7.avif',
    '8.avif',
    '9.avif',
    '10.webp',
    '11.avif',
    '12.avif',
];

const NftLaunchpadView = () => {
    return (
        <Grid container spacing={6} className='match-height'>
            {
                images.map((image, i) => {
                    return (
                        <Grid item xs={12} sm={6} md={4} lg={3}>
                            <NftMintCard image={image} />
                        </Grid>
                    )
                })
            }
        </Grid>
    );
};

export default NftLaunchpadView;
