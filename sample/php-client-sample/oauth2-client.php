<?php
require('lib/Client.php');
require('lib/GrantType/IGrantType.php');
require('lib/GrantType/AuthorizationCode.php');

const CLIENT_ID     = '<your_client_id>';
const CLIENT_SECRET = '<your_secret_key>';


const REDIRECT_URI           = '<your_callback_uri>';
const SERVICE_URI		     = '<your_cerberus_uri>'; // Ends with /
const AUTHORIZATION_ENDPOINT = SERVICE_URI + 'oauth/authorize';
const TOKEN_ENDPOINT         = SERVICE_URI + 'oauth/token';

$client = new OAuth2\Client(CLIENT_ID, CLIENT_SECRET);
if (!isset($_GET['code']))
{
    $auth_url = $client->getAuthenticationUrl(AUTHORIZATION_ENDPOINT, REDIRECT_URI);
    header('Location: ' . $auth_url);
    die('Redirect');
}
else
{
    $params = array('code' => $_GET['code'], 'redirect_uri' => REDIRECT_URI);
    $response = $client->getAccessToken(TOKEN_ENDPOINT, 'authorization_code', $params);
    $client->setAccessToken($response['result']['access_token']);
    $response = $client->fetch(SERVICE_URI + 'api/user.info.json');
    print_r($response['result']);
}
?>
