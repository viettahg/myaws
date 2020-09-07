<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Validator;
use App\User;

class JWTAuthController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:api', ['except'=>['login', 'register']]);
    }

    public function register(Request $request)
    {
        //Log::debug('An informational message.');
        //dd($request->all());
        
        $validator = Validator::make($request->all(),[
            'name'=>'required|between:2,100',
            'email'=>'required|email|unique:users|max:50',
            'password'=>'required|string|min:6',
        ]);

        

        if ($validator->fails())
        {
            //dd('1');
            return response()->json($validator->errors(), 422);
        }

        $user = User::create(array_merge(
            $validator->validated(),
            ['password'=>bcrypt($request->password)]
        ));

        //dump($user);

        return response()->json([
            'message'=>'Successfully registered',
            'user'=>$user
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(),[
            'email'=>'required|email',
            'password'=>'required|string|min:6',
        ]);

        if ($validator->fails())
        {
            return response()->json($validator->errors(), 422);
        }

        if (!$token = auth()->attempt($validator->validated()))
        {
            return response()->json(['error'=>'unauthorized'], 401);
        }

        return $this->createNewToken($token);
    }

    public function createNewToken($token)
    {
        return response()->json([
            'access_token'=>$token,
            'token_type'=>'bearer',
            'expires_in'=>auth()->factory()->getTTL()*60,
        ]);
    }
}
