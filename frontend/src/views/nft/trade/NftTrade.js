import { Grid } from "@mui/material";
import NftSaleCard from "../shared/NftSaleCard";

const images = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

const NftTradeView = () => {
    return (
        <Grid container spacing={6} className='match-height'>
            {
                images.map((image, i) => {
                    return (
                        <Grid item xs={12} sm={6} md={4} lg={3} xl={2}>
                            <NftSaleCard image={image} />
                        </Grid>
                    )
                })
            }
        </Grid>
    )
}

export default NftTradeView;
