<template>
    <v-main id="main">
    <v-container class="main-container mt-5">
        <v-card
        color="secondary"
        >
            <LoginForm />
        </v-card>
    </v-container>
    </v-main>
</template>

<style>
.main-container {
    width: fit-content;
}

::placeholder { /* Chrome, Firefox, Opera, Safari 10.1+ */
    color: #ffffffed;
}

:-ms-input-placeholder { /* Internet Explorer 10-11 */
    color: #ffffffed;
}

::-ms-input-placeholder { /* Microsoft Edge */
    color: #ffffffed;
}

#main {
    background: #f7f7f7;
}
</style>