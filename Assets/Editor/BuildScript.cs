using UnityEditor;
using UnityEngine;

public class BuildScript
{
    public static void BuildAndroid()
    {
        Debug.Log("BuildScript.BuildAndroid is called");
        string[] scenes = { "Assets/SampleScene.unity" };
        string outputPath = "aaa.apk";
        BuildPipeline.BuildPlayer(scenes, outputPath, BuildTarget.Android, BuildOptions.None);
        Debug.Log("BuildScript.BuildAndroid is exiting");
    }
}
