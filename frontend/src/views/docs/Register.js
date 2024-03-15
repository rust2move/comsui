// ** MUI Imports
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'

// ** Custom Components Imports
import CardSnippet from 'src/@core/components/card-snippet'

// ** Source code imports
import * as source from './RegisterSourceCode'

const RegisterVali = () => {        
    return (
        <Grid container spacing={6}>
            <Grid item xs={12}>
                <CardSnippet
                    title='1. Clone Commune Github'
                    code={{
                        tsx: null,
                        jsx: source.CloneCode
                    }}
                    sx={{
                        boxShadow: 'none',
                        backgroundColor: 'transparent',
                        border: theme => `1px solid ${theme.palette.divider}`
                    }}
                    >
                    <Typography sx={{ mb: 4 }}>
                        Clone commune ai github repository to install <code>c</code> command
                    </Typography>
                </CardSnippet>
            </Grid>

            <Grid item xs={12}>
                <CardSnippet
                    title='2. Install without Docker'
                    code={{
                        tsx: null,
                        jsx: source.InstallCode
                    }}
                    sx={{
                        boxShadow: 'none',
                        backgroundColor: 'transparent',
                        border: theme => `1px solid ${theme.palette.divider}`
                    }}
                    >
                    <Typography sx={{ mb: 4 }}>
                        <code>git</code> should be already installed
                    </Typography>
                </CardSnippet>
            </Grid>

            <Grid item xs={12}>
                <CardSnippet
                    title='3. Register validator'
                    code={{
                        tsx: null,
                        jsx: source.RegisterCode
                    }}
                    sx={{
                        boxShadow: 'none',
                        backgroundColor: 'transparent',
                        border: theme => `1px solid ${theme.palette.divider}`
                    }}
                    >
                    <Typography sx={{ mb: 4 }}>
                        Register validator and get your emissions
                    </Typography>
                </CardSnippet>
            </Grid>
        </Grid>
    )
}

export default RegisterVali
