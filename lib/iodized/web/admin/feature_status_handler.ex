defmodule Iodized.Web.Admin.FeatureStatusHandler do

  @persistence Iodized.FeaturePersistence.Mnesia

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def rest_init(req, _opts) do
    state = %{feature: nil}
    {:ok, req, state}
  end

  def allowed_methods(req, state) do
    {["GET", "PUT", "DELETE"], req, state}
  end

  def resource_exists(req, state) do
    {feature_id, req} = :cowboy_req.binding(:feature_id, req)
    case @persistence.find_feature(feature_id) do
      :not_found ->     {false, req, state}
      {:ok, feature} -> state = %{state| feature: feature}
                        {true, req, state}
    end
  end

  def content_types_provided(req, state) do
    providers = [
      {{"application", "json", :*}, :render_feature}
    ]
    {providers, req, state}
  end

  def render_feature(req, state) do
    req = :cowboy_req.set_resp_header("content-type", "application/json; charset=utf-8", req)
    body = state.feature |> Iodized.Feature.json |> JSEX.encode!(indent: 2)
    {body, req, state}
  end

  def content_types_accepted(req, state) do
    acceptors = [
      {{"application", "json", :*}, :save_feature}
    ]
    {acceptors, req, state}
  end

  def save_feature(req, state) do
    {:ok, feature_json, req} = :cowboy_req.body(req)
    feature = feature_json |> JSEX.decode!(labels: :atom) |> Iodized.Feature.from_json
    @persistence.save_feature(feature)
    Iodized.Notification.notify_event("update",
                                      "Updated feature " <> Iodized.Feature.feature_description(feature))
    {true, req, state}
  end

  def delete_resource(req, state) do
    {feature_id, req} = :cowboy_req.binding(:feature_id, req)

    {:ok, feature} = @persistence.find_feature(feature_id)

    @persistence.delete_feature(feature_id)
    Iodized.Notification.notify_event("delete",
                                      "Deleted feature " <> Iodized.Feature.feature_description(feature))
    {true, req, state}
  end
end
